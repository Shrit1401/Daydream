import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:ui';

class SingleNote extends StatefulWidget {
  const SingleNote({super.key});

  @override
  State<SingleNote> createState() => _SingleNoteState();
}

class _SingleNoteState extends State<SingleNote> {
  final _dateController = TextEditingController(text: '18 / 11 / 22');
  final _contentController = TextEditingController(
    text:
        'we have started the analytics phase. we need test access to the app to try out the existing features.\n\nwe need to coordinate a call with management to understand how soon we can start wireframes.\n\nask the client to collect positive and negative references that will help in the work on the concept.',
  );

  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    // Initialize with some basic formatting options
    _controller = QuillController(
      document: Document()..insert(0, _contentController.text),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _contentController.dispose();
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
                  Text(
                    _dateController.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Main editor with floating toolbar at the bottom
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
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                const HorizontalSpacing(0, 0),
                                const VerticalSpacing(0, 0),
                                const VerticalSpacing(0, 0),
                                null,
                              ),
                              h1: DefaultTextBlockStyle(
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
                              h2: DefaultTextBlockStyle(
                                GoogleFonts.dmSans(
                                  fontSize: 20,
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
                                  fontSize: 18,
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
                            color: Colors.white.withOpacity(0.85),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              child: QuillSimpleToolbar(
                                controller: _controller,
                                config: QuillSimpleToolbarConfig(
                                  showBoldButton: true,
                                  showItalicButton: true,
                                  showUnderLineButton: true,
                                  showStrikeThrough: true,
                                  showListBullets: true,
                                  showListCheck: true,
                                  showListNumbers: true,
                                  showHeaderStyle: true,
                                  showClearFormat: true,
                                  showFontFamily: false,
                                  showSearchButton: false,
                                  showCodeBlock: false,
                                  showInlineCode: false,
                                  showQuote: false,
                                  showIndent: false,
                                  showLink: false,
                                  showBackgroundColorButton: false,
                                  showColorButton: false,
                                  showSubscript: false,
                                  showSuperscript: false,
                                  multiRowsDisplay: false,
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
