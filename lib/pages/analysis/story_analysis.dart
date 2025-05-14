import 'package:flutter/material.dart';
import 'package:daydream/components/analysis/gradient_background.dart';
import 'package:daydream/components/analysis/analysis_content.dart';

class StoryAnalysisPage extends StatefulWidget {
  const StoryAnalysisPage({super.key});

  @override
  State<StoryAnalysisPage> createState() => _StoryAnalysisPageState();
}

class _StoryAnalysisPageState extends State<StoryAnalysisPage>
    with TickerProviderStateMixin {
  bool _hasStarted = false;
  bool _isGradientActive = true;
  late AnimationController _slideController;
  late AnimationController _colorController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );

    _textColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    // Start the slide animation
    await _slideController.forward();

    // Wait for the slide to complete before removing gradient
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isGradientActive = false;
      });
    }

    // Wait a bit before starting color transition
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _hasStarted = true;
      });
      await _colorController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_colorController, _slideController]),
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          backgroundColor: _backgroundColorAnimation.value ?? Colors.white,
          body: Stack(
            children: [
              // Gradient background
              if (_isGradientActive)
                GradientBackground(
                  slideAnimation: _slideAnimation,
                  fadeAnimation: _fadeAnimation,
                ),

              // Main content
              AnalysisContent(
                hasStarted: _hasStarted,
                textColorAnimation: _textColorAnimation,
                onStartAnalysis: _startAnalysis,
              ),
            ],
          ),
        );
      },
    );
  }
}
