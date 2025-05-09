import 'package:daydream/components/instrument_text.dart';
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
  final date = "18 May 2025";

  final QuillController _controller = QuillController.basic();

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
                  InstrumentText(date, fontSize: 32),
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
