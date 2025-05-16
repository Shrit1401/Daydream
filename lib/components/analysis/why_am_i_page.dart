import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/utils/ai/ai_story.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WhyAmIPage extends StatefulWidget {
  final String personalityWord;
  final Color textColor;

  const WhyAmIPage({
    super.key,
    required this.personalityWord,
    required this.textColor,
  });

  @override
  State<WhyAmIPage> createState() => _WhyAmIPageState();
}

class _WhyAmIPageState extends State<WhyAmIPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _explanation = '';
  String _tldr = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _generateExplanation();
  }

  Future<void> _generateExplanation() async {
    final notes = await HiveLocal.getAllNotes();
    final recentNotes = notes.take(10).toList();
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Storyteller';

    final entriesText = recentNotes
        .map((note) {
          final date = note.date;
          return '''
Entry from ${date.year}-${date.month}-${date.day}:
${note.plainContent}
''';
        })
        .join('\n---\n');

    final prompt =
        '''Based on the personality trait "${widget.personalityWord}" and these recent journal entries, write a magical fairy-tale style story that begins with "Once upon a time there was $userName". 
    Structure the story in three parts:
    1. Beginning: Start with a problem or challenge that shows the personality trait
    2. Middle: Show how the personality trait leads to an exciting climax or turning point
    3. Ending: Show how the personality trait helps solve the problem or leads to a happy ending
    
    Use simple, easy-to-understand words that a child could understand. Avoid complex vocabulary or fancy words.
    Weave together the user's experiences and their personality trait in a whimsical, enchanting way.
    Keep it concise (2-3 paragraphs) but magical. Use simple fairy-tale like imagery and metaphors that everyone can understand.
    
    Journal entries:
    $entriesText''';

    final tldrPrompt =
        '''Based on the personality trait "${widget.personalityWord}" and the journal entries, write a simple one-line summary that captures the story's journey from problem to solution.
    Use easy words that anyone can understand. Make it sound like a simple fairy-tale lesson. Keep it under 100 characters.''';

    try {
      final response = await StoryGenerator.generateContent(prompt);
      final tldrResponse = await StoryGenerator.generateContent(tldrPrompt);
      if (mounted) {
        setState(() {
          _explanation = response.trim();
          _tldr = tldrResponse.trim();
          _isLoading = false;
        });
        _controller.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _explanation =
              "Oops! Even our AI got tongue-tied trying to explain your amazing personality. But hey, that just makes you even more unique!";
          _tldr = "You're so unique, even our AI needs a dictionary!";
          _isLoading = false;
        });
        _controller.forward();
      }
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: widget.textColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Story.',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.textColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textColor,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Analyzing your personality...',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: widget.textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: widget.textColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: widget.textColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TLDR',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: widget.textColor.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _tldr,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: widget.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).popUntil((route) => route.isFirst);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.textColor,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Go to Home',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              _explanation,
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                height: 1.6,
                                color: widget.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
