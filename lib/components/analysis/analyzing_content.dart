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
  bool _isLoading = true;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;
  late final AnimationController _textFadeController;
  late final Animation<double> _topTextOpacity;
  late final Animation<double> _wordOpacity;
  late final List<Animation<double>> _dotAnimations;
  final int _numDots = 3;

  @override
  void initState() {
    super.initState();

    // Initialize all animation controllers first
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

    // Initialize animations
    _topTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textFadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _wordOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textFadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _dotAnimations = List.generate(_numDots, (index) {
      // Calculate start and end points for each dot's animation
      // Distribute evenly across the duration
      final startPercent = index / _numDots;
      final endPercent = startPercent + (1 / (_numDots * 2));

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dotsController,
          curve: Interval(startPercent, endPercent, curve: Curves.easeInOut),
        ),
      );
    });

    // Start loading the description
    _loadUserDescription();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDescription() async {
    try {
      final notes = await HiveLocal.getAllNotes();
      final generatedNotes =
          notes.where((note) => note.isGenerated).toList()..sort(
            (a, b) => b.date.compareTo(a.date),
          ); // Sort by most recent first

      if (generatedNotes.isEmpty) {
        setState(() {
          _userDescription = 'mysterious';
          _isLoading = false;
        });
        _textFadeController.forward();
        return;
      }

      // Take up to 10 most recent entries
      final recentNotes = generatedNotes.take(10).toList();

      // Create a combined journal entries string
      final entriesText = recentNotes
          .map((note) {
            final date = note.date;
            return '''
Entry from ${date.year}-${date.month}-${date.day}:
${note.plainContent}
''';
          })
          .join('\n---\n');

      // Create a prompt for the AI to generate a single-word description
      final prompt =
          '''Based on these journal entries, give me ONE single word (no explanation, just the word) that best describes the person's core characteristic or essence. The word should be simple but dramatic — like "explorer", "sulker", or "dreamer". Avoid generic emotions like "happy" or "sad", and avoid abstract roles like "observer" or "deep diver". Instead, lean toward expressive traits like "overthinker", "emotional", or "romantic".

Consider the patterns, recurring themes, and overall tone across all entries to capture their true essence.

Journal entries:
$entriesText''';

      // Get AI-generated description
      final response = await StoryGenerator.generateContent(prompt);

      // Clean up the response to ensure we get just one word
      final cleanWord = response
          .trim()
          .split(' ')
          .first
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z]'), '');

      setState(() {
        _userDescription = cleanWord;
        _isLoading = false;
      });
      _textFadeController.forward();
    } catch (e) {
      setState(() {
        _userDescription = 'unique';
        _isLoading = false;
      });
      _textFadeController.forward();
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        if (_isLoading)
          _buildLoadingAnimation()
        else
          Column(
            children: [
              FadeTransition(
                opacity: _topTextOpacity,
                child: InstrumentText(
                  "if we describe you in words, we'd say you're",
                  fontSize: 36,
                  color: widget.textColorAnimation.value ?? Colors.black,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _wordOpacity,
                child: InstrumentText(
                  _userDescription,
                  fontSize: 48,
                  color: widget.textColorAnimation.value ?? Colors.black,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
