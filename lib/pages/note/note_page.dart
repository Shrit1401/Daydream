import 'package:daydream/components/instrument_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:ui';
import 'package:daydream/utils/utils.dart';
import 'package:daydream/utils/types.dart';

class SingleNote extends StatefulWidget {
  final Note note;
  const SingleNote({super.key, required this.note});

  @override
  State<SingleNote> createState() => _SingleNoteState();
}

class _SingleNoteState extends State<SingleNote> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.note.content.isNotEmpty) {
      _controller = QuillController(
        document: Document.fromJson(widget.note.content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _controller = QuillController.basic();
    }
    _controller.readOnly = widget.note.isGenerated;

    if (widget.note.isGenerated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only read this note. To write your new note, write in today\'s note.',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
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
                  if (widget.note.isGenerated)
                    const SizedBox(
                      width: 44 * 2,
                    ), // To balance the space for undo/redo
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
                        child: QuillEditor.basic(
                          controller: _controller,
                          config: QuillEditorConfig(
                            placeholder: 'Write your thoughts freely...',
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
                                    color: Colors.grey.withValues(
                                      red: 128,
                                      green: 128,
                                      blue: 128,
                                      alpha: 102,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
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
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
