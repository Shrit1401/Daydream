import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/routes.dart';
import 'package:daydream/utils/types/types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:ui';
import 'dart:async';
import 'package:daydream/utils/utils.dart';
import 'package:daydream/utils/ai/ai_story.dart';
import 'package:daydream/pages/chat/chat_page.dart';

class SingleNote extends StatefulWidget {
  final Note note;
  const SingleNote({super.key, required this.note});

  @override
  State<SingleNote> createState() => _SingleNoteState();
}

class _SingleNoteState extends State<SingleNote> {
  late final QuillController _controller;
  late Note _currentNote;

  //check mark
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _showCheckmark = false;
  Timer? _saveTimer;
  Timer? _checkmarkTimer;

  //generating
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;

    if (widget.note.content.isNotEmpty) {
      final content = List<Map<String, dynamic>>.from(
        widget.note.content.map((item) => Map<String, dynamic>.from(item)),
      );

      if (content.isNotEmpty) {
        final lastDelta = content.last;
        if (lastDelta['insert'] is String &&
            !(lastDelta['insert'] as String).endsWith('\n')) {
          content.last = {'insert': '${lastDelta['insert']}\n'};
        }
      }

      _controller = QuillController(
        document: Document.fromJson(content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
    _controller.readOnly = widget.note.isGenerated;

    // Add listener for content changes
    _controller.document.changes.listen(
      (event) {
        if (!mounted) return;

        setState(() {
          _hasUnsavedChanges = true;
          _isSaving = true;
        });

        // Cancel any existing timer
        _saveTimer?.cancel();

        // Start a new timer to save after 1 second of no changes
        _saveTimer = Timer(const Duration(seconds: 1), () {
          if (_hasUnsavedChanges) {
            _saveNote();
          }
        });
      },
      onError: (error) {
        //  handle error
      },
    );

    if (widget.note.isGenerated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'This is a generated note - write in today\'s note instead',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.black87,
              duration: const Duration(seconds: 1),
              margin: const EdgeInsets.all(8),
            ),
          );
        }
      });
    }
  }

  Future<void> _saveNote() async {
    if (!mounted) return;

    final content = _controller.document.toPlainText();
    final delta = List<Map<String, dynamic>>.from(
      _controller.document.toDelta().toJson().map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );

    // Ensure the document ends with a newline
    if (delta.isNotEmpty) {
      final lastDelta = delta.last;
      if (lastDelta['insert'] is String &&
          !(lastDelta['insert'] as String).endsWith('\n')) {
        delta.last = {'insert': '${lastDelta['insert']}\n'};
      }
    }

    // Only save if there are actual changes
    if (content != _currentNote.plainContent) {
      try {
        // Update the note
        _currentNote = Note(
          date: _currentNote.date,
          content: delta,
          plainContent: content,
          id: _currentNote.id,
          isGenerated: _currentNote.isGenerated,
          tags: _currentNote.tags,
          mood: _currentNote.mood,
          reflect: _currentNote.reflect,
          title: _currentNote.title,
          isCustom: _currentNote.isCustom,
        );

        // Save to Hive
        await HiveLocal.saveNote(_currentNote);

        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
            _isSaving = false;
            _showCheckmark = true;
          });
          _checkmarkTimer?.cancel();
          _checkmarkTimer = Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _showCheckmark = false;
              });
            }
          });
        }
      } catch (e) {
        print('Error saving note: $e');
        if (mounted) {
          setState(() {
            _isSaving = false;
            _showCheckmark = false;
          });
        }
      }
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _checkmarkTimer?.cancel();
    // Save any unsaved changes before disposing
    if (_hasUnsavedChanges) {
      _saveNote();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back navigation while saving
        if (_isSaving) return false;
        if (_hasUnsavedChanges) {
          await _saveNote();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                      onPressed:
                          _isSaving
                              ? null
                              : () async {
                                if (_hasUnsavedChanges) {
                                  await _saveNote();
                                }
                                if (mounted) {
                                  // Always pop with the current note to trigger a refresh
                                  Navigator.of(context).pop(_currentNote);
                                }
                              },
                    ),
                    if (!widget.note.isCustom)
                      Expanded(
                        child: Center(
                          child: InstrumentText(
                            '${widget.note.date.day} ${getMonthName(widget.note.date.month)} ${widget.note.date.year.toString().substring(2)}',
                            fontSize: 32,
                          ),
                        ),
                      ),
                    if (!widget.note.isGenerated)
                      Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                _isSaving
                                    ? Padding(
                                      key: const ValueKey('saving'),
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.grey[600]!,
                                              ),
                                        ),
                                      ),
                                    )
                                    : _showCheckmark
                                    ? Padding(
                                      key: const ValueKey('checkmark'),
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 22,
                                      ),
                                    )
                                    : const SizedBox(width: 28),
                          ),
                          IconButton(
                            icon: const Icon(Icons.undo, size: 22),
                            tooltip: 'Undo',
                            onPressed: () {
                              _controller.undo();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.redo, size: 22),
                            tooltip: 'Redo',
                            onPressed: () {
                              _controller.redo();
                            },
                          ),
                        ],
                      ),
                    if (widget.note.isGenerated) const SizedBox(width: 44 * 2),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    children: [
                      // The main editor
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              _currentNote.isCustom &&
                                      _currentNote.title != null
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: InstrumentText(
                                          _currentNote.title!,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Expanded(
                                        child: QuillEditor.basic(
                                          controller: _controller,
                                          config: QuillEditorConfig(
                                            placeholder:
                                                'Write your thoughts freely...',
                                            customStyles: DefaultStyles(
                                              paragraph: DefaultTextBlockStyle(
                                                GoogleFonts.dmSans(
                                                  fontSize: 20,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                const HorizontalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                null,
                                              ),
                                              h1: DefaultTextBlockStyle(
                                                GoogleFonts.dmSans(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                const HorizontalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                null,
                                              ),
                                              h2: DefaultTextBlockStyle(
                                                GoogleFonts.dmSans(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                const HorizontalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                null,
                                              ),
                                              h3: DefaultTextBlockStyle(
                                                GoogleFonts.dmSans(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                const HorizontalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                const VerticalSpacing(0, 0),
                                                null,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : QuillEditor.basic(
                                    controller: _controller,
                                    config: QuillEditorConfig(
                                      placeholder:
                                          'Write your thoughts freely...',
                                      customStyles: DefaultStyles(
                                        paragraph: DefaultTextBlockStyle(
                                          GoogleFonts.dmSans(
                                            fontSize: 20,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          const HorizontalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          null,
                                        ),
                                        h1: DefaultTextBlockStyle(
                                          GoogleFonts.dmSans(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          const HorizontalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          null,
                                        ),
                                        h2: DefaultTextBlockStyle(
                                          GoogleFonts.dmSans(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          const HorizontalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          null,
                                        ),
                                        h3: DefaultTextBlockStyle(
                                          GoogleFonts.dmSans(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          const HorizontalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          const VerticalSpacing(0, 0),
                                          null,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                      // Floating toolbar at the bottom with glass effect
                      if (!widget.note.isGenerated)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Material(
                                elevation: 16,
                                borderRadius: BorderRadius.circular(18),
                                color: Colors.white,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: QuillSimpleToolbar(
                                            controller: _controller,
                                            config: QuillSimpleToolbarConfig(
                                              color: Colors.white,
                                              showBoldButton: true,
                                              showItalicButton: false,
                                              showUnderLineButton: false,
                                              showStrikeThrough: false,
                                              showListBullets: true,
                                              showListCheck: false,
                                              showListNumbers: false,
                                              showHeaderStyle: true,
                                              showClearFormat: false,
                                              showFontFamily: false,
                                              showSearchButton: false,
                                              showCodeBlock: false,
                                              showInlineCode: false,
                                              showQuote: false,
                                              showIndent: false,
                                              showLink: false,
                                              showBackgroundColorButton: false,
                                              showUndo: false,
                                              showRedo: false,
                                              showColorButton: false,
                                              showSubscript: false,
                                              showSuperscript: false,
                                              showFontSize: false,
                                              multiRowsDisplay: false,
                                              toolbarSize: 15 * 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_currentNote.isGenerated)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      label: const Text(
                        'Chat with Journal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(note: _currentNote),
                          ),
                        );
                      },
                    ),
                  ),
                if (_currentNote.isCustom && !_currentNote.isGenerated)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      label: Text(
                        _isGenerating ? 'Generating...' : 'Generate Response',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (_isSaving) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please wait for the note to save',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.orangeAccent,
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                            return;
                          }
                        }
                        setState(() {
                          _isGenerating = true;
                        });
                        try {
                          final generatedNote = await generateStory(
                            _currentNote,
                          );
                          // Preserve custom fields
                          final lockedNote = Note(
                            date: generatedNote.date,
                            content: generatedNote.content,
                            plainContent: generatedNote.plainContent,
                            id: generatedNote.id,
                            isGenerated: true,
                            tags: generatedNote.tags,
                            mood: generatedNote.mood,
                            reflect: generatedNote.reflect,
                            title: _currentNote.title,
                            isCustom: _currentNote.isCustom,
                          );
                          await HiveLocal.saveNote(lockedNote);
                          Navigator.pushNamed(context, DreamRoutes.homeRoute);
                          // final newContent = List<Map<String, dynamic>>.from(
                          //   lockedNote.content.map(
                          //     (item) => Map<String, dynamic>.from(item),
                          //   ),
                          // );
                          // final newController = QuillController(
                          //   document: Document.fromJson(newContent),
                          //   selection: const TextSelection.collapsed(offset: 0),
                          // );
                          // newController.readOnly = true;
                          // final oldController = _controller;
                          // _controller = newController;
                          // WidgetsBinding.instance.addPostFrameCallback((_) {
                          //   oldController.dispose();
                          // });

                          // go to the note page

                          setState(() {
                            _currentNote = lockedNote;
                            _isGenerating = false;
                          });
                        } catch (e) {
                          setState(() {
                            _isGenerating = false;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
