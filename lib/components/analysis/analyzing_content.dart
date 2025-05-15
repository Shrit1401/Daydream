import 'package:flutter/material.dart';
import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/utils/hive/hive_local.dart';
import 'package:daydream/utils/ai/ai_story.dart';

class AnalyzingContent extends StatefulWidget {
  final Animation<Color?> textColorAnimation;

  const AnalyzingContent({super.key, required this.textColorAnimation});

  @override
  State<AnalyzingContent> createState() => _AnalyzingContentState();
}

class _AnalyzingContentState extends State<AnalyzingContent>
    with TickerProviderStateMixin {
  String _userDescription = '';
  String _moodTag = '';
  bool _isLoading = true;

  // Animation controllers
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final AnimationController _textFadeController;
  late final AnimationController _backgroundController;

  // Animations
  late final Animation<double> _topTextOpacity;
  late final Animation<double> _wordOpacity;
  Animation<Offset> _slideAnimation = AlwaysStoppedAnimation<Offset>(
    Offset.zero,
  );
  late final List<Animation<double>> _dotAnimations;

  // Constants
  final int _numDots = 3;
  final String happyImage = "images/wall/happy.png";
  final String sadImage = "images/wall/sad.png";
  final String neutralImage = "images/wall/nuetral.png";

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
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    // Override the initial _slideAnimation with the actual animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textFadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
      ),
    );

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
          _moodTag = 'balanced';
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

      // Get mood tag
      final promptTag =
          '''Based on these journal entries, analyze the overall emotional tone and respond with exactly one word from these three options: "happy", "sad", or "balanced". Just the word, no explanation.

Journal entries:
$entriesText''';

      // Get both responses
      final response = await StoryGenerator.generateContent(prompt);
      final moodResponse = await StoryGenerator.generateContent(promptTag);

      final cleanWord = response
          .trim()
          .split(' ')
          .first
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z]'), '');

      final cleanMood = moodResponse.trim().toLowerCase().replaceAll(
        RegExp(r'[^a-z]'),
        '',
      );

      setState(() {
        _userDescription = cleanWord;
        _moodTag = cleanMood;
        _isLoading = false;
      });

      // Start the text animation which will also fade in the background
      await _textFadeController.forward();
    } catch (e) {
      setState(() {
        _userDescription = 'unique';
        _moodTag = 'balanced';
        _isLoading = false;
      });
      _textFadeController.forward();
    }
  }

  String get _backgroundImage {
    switch (_moodTag) {
      case 'happy':
        return happyImage;
      case 'sad':
        return sadImage;
      default:
        return neutralImage;
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
        FadeTransition(
          opacity: _wordOpacity,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage(_backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned.fill(
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
                ],
              ),
            ],
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
                          Colors.purple.withOpacity(0.3),
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
                        color: Colors.black.withOpacity(0.1),
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
