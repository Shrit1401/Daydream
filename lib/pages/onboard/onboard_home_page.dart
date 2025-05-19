import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/components/instrument_text.dart';
import 'dart:ui';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/types/types.dart';
import 'dart:async';
import 'package:daydream/utils/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardHomePage extends StatefulWidget {
  const OnboardHomePage({super.key});

  @override
  State<OnboardHomePage> createState() => _OnboardHomePageState();
}

class _OnboardHomePageState extends State<OnboardHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showInput = false;
  QuillController? _quillController;
  bool _isSaving = false;
  bool _showCheckmark = false;
  Timer? _saveTimer;
  Timer? _checkmarkTimer;
  late SharedPreferences _prefs;
  int _currentPage = 0;
  final List<Map<String, dynamic>> _onboardingContent = [
    {
      'title': 'write freely.',
      'description':
          'dump whatever\'s in your brain. zero judgment. NO third-party AI calls — our servers nuke your data after 24hrs. your thoughts = your business.',
      'hasImage': false,
    },
    {
      'title': 'talking journal.',
      'description':
          'new entry daily, get mood insights at midnight. magic but actually useful lol.',
      'hasImage': false,
    },
    {
      'title': 'dear diary.',
      'description':
          'deeper dive into your feels whenever. all data stays on your device. we literally can\'t see it.',
      'hasImage': false,
    },
    {
      'title': 'privacy first. fr fr.',
      'description':
          'psycho about privacy. no data leaving your device. no tracking. no selling your thoughts. built this bc we wanted it.',
      'hasImage': false,
    },
    {
      'title': 'your life as a story.',
      'description':
          'our insane feature turns your entries into a story of your life. actually mind-blowing. just try it.',
      'hasImage': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controller.dispose();
    _quillController?.dispose();
    _saveTimer?.cancel();
    _checkmarkTimer?.cancel();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingContent.length - 1) {
      _controller.forward().then((_) {
        setState(() {
          _currentPage++;
        });
        _controller.reverse();
      });
    } else {
      _controller.forward().then((_) {
        _showStoryInput();
      });
    }
  }

  void _showStoryInput() {
    _quillController ??= QuillController.basic();
    _quillController!.document.changes.listen((event) {
      if (!mounted) return;

      setState(() {});
    });
    setState(() {
      _showInput = true;
    });
    _controller.reverse();
  }

  Future<void> _saveStory() async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    final content = _quillController!.document.toPlainText();
    final delta = List<Map<String, dynamic>>.from(
      _quillController!.document.toDelta().toJson().map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );

    if (delta.isNotEmpty) {
      final lastDelta = delta.last;
      if (lastDelta['insert'] is String &&
          !(lastDelta['insert'] as String).endsWith('\n')) {
        delta.last = {'insert': '${lastDelta['insert']}\n'};
      }
    }

    try {
      final note = Note(
        date: DateTime.now(),
        content: delta,
        plainContent: content,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isGenerated: false,
        tags: [],
        mood: null,
        reflect: null,
        title: 'My Story',
        isCustom: true,
      );

      await HiveLocal.saveNote(note);
      await _prefs.setBool('onboarded_signup', true);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _showCheckmark = true;
        });

        // Navigate after a short delay to show the checkmark
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DreamRoutes.storyAnalysisRoute,
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _showCheckmark = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                _showInput
                    ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InstrumentText(
                            'Write Your Story',
                            fontSize: 42,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Share your thoughts, dreams, or maybe who you really are.',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              color: Colors.black54,
                              height: 1.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.black.withValues(
                                        alpha: .05,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child:
                                      _quillController != null
                                          ? QuillEditor.basic(
                                            controller: _quillController!,
                                            config: QuillEditorConfig(
                                              expands: true,
                                              placeholder:
                                                  'Start writing here...',
                                              customStyles: DefaultStyles(
                                                paragraph:
                                                    DefaultTextBlockStyle(
                                                      GoogleFonts.dmSans(
                                                        fontSize: 20,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      const HorizontalSpacing(
                                                        0,
                                                        0,
                                                      ),
                                                      const VerticalSpacing(
                                                        0,
                                                        0,
                                                      ),
                                                      const VerticalSpacing(
                                                        0,
                                                        0,
                                                      ),
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
                                          )
                                          : const Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.black,
                                                  ),
                                            ),
                                          ),
                                ),
                                if (_quillController != null)
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Material(
                                          elevation: 16,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          color: Colors.black,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.black.withValues(
                                                  alpha: 0.1,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                    horizontal: 12,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: QuillSimpleToolbar(
                                                      controller:
                                                          _quillController!,
                                                      config: QuillSimpleToolbarConfig(
                                                        color: Colors.white70,
                                                        showBoldButton: true,
                                                        showItalicButton: false,
                                                        showUnderLineButton:
                                                            false,
                                                        showStrikeThrough:
                                                            false,
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
                                                        showBackgroundColorButton:
                                                            false,
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
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    _isSaving
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                        : _showCheckmark
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 22,
                                        )
                                        : const SizedBox(width: 22),
                              ),
                              IconButton(
                                onPressed: _saveStory,
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C2C2C),
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '🔒 everything you build stays on your device - your privacy is our top priority',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InstrumentText(
                          'hey there 👋',
                          fontSize: 42,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ready to start building something awesome?',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.black54,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        Expanded(
                          child: Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InstrumentText(
                                    _onboardingContent[_currentPage]['title']!,
                                    fontSize: 42,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Text(
                                      _onboardingContent[_currentPage]['description']!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        color: Colors.black54,
                                        height: 1.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _nextPage,
                            icon: Icon(
                              _currentPage < _onboardingContent.length - 1
                                  ? Icons.arrow_forward
                                  : Icons.edit,
                              color: Colors.black,
                              size: 28,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.05,
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
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
