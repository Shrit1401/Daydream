import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/ai/ai_story.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:daydream/components/analysis/why_am_i_page.dart';

class AnalyzingContent extends StatefulWidget {
  final Animation<Color?> textColorAnimation;

  const AnalyzingContent({super.key, required this.textColorAnimation});

  @override
  State<AnalyzingContent> createState() => _AnalyzingContentState();
}

class _AnalyzingContentState extends State<AnalyzingContent>
    with TickerProviderStateMixin {
  String _userDescription = '';
  bool _isLoading = true;
  String? _selectedBackground;
  String _funnyExplanation = '';

  // Animation controllers
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final AnimationController _textFadeController;
  late final AnimationController _backgroundController;

  final name = FirebaseAuth.instance.currentUser?.displayName;

  // Animations
  late final Animation<double> _topTextOpacity;
  late final Animation<double> _wordOpacity;
  Animation<double> _backgroundOpacity = const AlwaysStoppedAnimation(0.0);
  late final List<Animation<double>> _dotAnimations;

  // Constants
  final int _numDots = 3;
  final List<String> _backgroundImages = [
    "images/wall/happy.png",
    "images/wall/sad.png",
    "images/wall/nuetral.png",
  ];

  // Add GlobalKey for capturing the widget
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserDescription();
  }

  void _initializeAnimations() {
    // Initialize controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _selectRandomBackground();
        _backgroundController.forward();
      }
    });

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _topTextOpacity = CurvedAnimation(
      parent: _textFadeController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _wordOpacity = CurvedAnimation(
      parent: _textFadeController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    // Override the initial _slideAnimation with the actual animation

    // Initialize dot animations
    _dotAnimations = List.generate(_numDots, (index) {
      final startPercent = index / _numDots;
      final endPercent = startPercent + (1 / (_numDots * 2));

      return CurvedAnimation(
        parent: _dotsController,
        curve: Interval(startPercent, endPercent, curve: Curves.easeInOut),
      );
    });
  }

  void _selectRandomBackground() {
    if (mounted) {
      setState(() {
        _selectedBackground =
            _backgroundImages[Random().nextInt(_backgroundImages.length)];
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _textFadeController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDescription() async {
    try {
      final notes = await HiveLocal.getAllNotes();
      final generatedNotes =
          notes.where((note) => note.isGenerated).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      if (generatedNotes.isEmpty) {
        setState(() {
          _userDescription = 'mysterious';
          _funnyExplanation =
              'You\'re mysterious because even your journal is playing hide and seek!';
          _isLoading = false;
        });
        _textFadeController.forward();
        return;
      }

      final recentNotes = generatedNotes.take(10).toList();

      final entriesText = recentNotes
          .map((note) {
            final date = note.date;
            return '''
Entry from ${date.year}-${date.month}-${date.day}:
${note.plainContent}
''';
          })
          .join('\n---\n');

      // Get personality description
      final prompt =
          '''Based on these journal entries, give me ONE single word (no explanation, just the word) that best describes the person's core characteristic or essence. The word should be simple but dramatic — like "explorer", "sulker", or "dreamer". Avoid generic emotions like "happy" or "sad", and avoid abstract roles like "observer" or "deep diver". Instead, lean toward expressive traits like "overthinker", "emotional", or "romantic".

Consider the patterns, recurring themes, and overall tone across all entries to capture their true essence.

Journal entries:
$entriesText''';

      // Get response
      final response = await StoryGenerator.generateContent(prompt);

      final cleanWord = response
          .trim()
          .split(' ')
          .first
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z]'), '');

      // Get funny explanation
      final funnyPrompt =
          '''Based on the word "$cleanWord", write a funny, one-line explanation of why someone might be described this way. Keep it under 100 characters. Your Name is $name. Example: "Shrit is a dreamer because his head is always in the clouds, and his feet are probably there too!"''';

      final funnyResponse = await StoryGenerator.generateContent(funnyPrompt);

      setState(() {
        _userDescription = cleanWord;
        _funnyExplanation = funnyResponse.trim();
        _isLoading = false;
      });

      // Start the text animation which will also fade in the background
      await _textFadeController.forward();
    } catch (e) {
      setState(() {
        _userDescription = 'unique';
        _funnyExplanation =
            'You\'re unique because even the AI got confused trying to describe you!';
        _isLoading = false;
      });
      _textFadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [const SizedBox(height: 80), _buildLoadingAnimation()],
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        if (_selectedBackground != null)
          FadeTransition(
            opacity: _backgroundOpacity,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage(_selectedBackground!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

        // Wrap the content in RepaintBoundary with GlobalKey
        RepaintBoundary(
          key: _globalKey,
          child: Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Column(
                  children: [
                    FadeTransition(
                      opacity: _topTextOpacity,
                      child: InstrumentText(
                        "if we describe you in words, we'd say you're",
                        fontSize: 36,
                        color: widget.textColorAnimation.value ?? Colors.white,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _wordOpacity,
                      child: InstrumentText(
                        _userDescription,
                        fontSize: 48,
                        color: widget.textColorAnimation.value ?? Colors.white,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _wordOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _funnyExplanation,
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color:
                                widget.textColorAnimation.value ?? Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: FadeTransition(
            opacity: _wordOpacity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WhyAmIPage(
                              personalityWord: _userDescription,
                              textColor:
                                  widget.textColorAnimation.value ??
                                  Colors.white,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: Colors.black.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_dotsController),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(_pulseController),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: 0.6,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        InstrumentText(
          "Analyzing your story",
          fontSize: 24,
          color: widget.textColorAnimation.value ?? Colors.black,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_numDots, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FadeTransition(
                opacity: _dotAnimations[index],
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.textColorAnimation.value ?? Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
