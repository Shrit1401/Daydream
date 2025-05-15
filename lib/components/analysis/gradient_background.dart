import 'package:flutter/material.dart';

class GradientBackground extends StatefulWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const GradientBackground({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentColorSetIndex = 0;

  // Multiple color sets with purple theme
  final List<List<Color>> colorSets = [
    [
      Colors.white,
      Colors.purple.withOpacity(0.7),
      Colors.deepPurple,
      Colors.purpleAccent,
    ],
    [
      Colors.white,
      Color(0xFF9C27B0).withOpacity(0.7), // Purple
      Color(0xFF673AB7), // Deep Purple
      Color(0xFF3F51B5), // Indigo
    ],
    [
      Colors.white,
      Color(0xFFAB47BC).withOpacity(0.7), // Purple 400
      Color(0xFF7E57C2), // Deep Purple 400
      Color(0xFF5E35B1), // Deep Purple 600
    ],
    [
      Colors.white,
      Color(0xFF9575CD).withOpacity(0.7), // Deep Purple 300
      Color(0xFF7986CB), // Indigo 300
      Color(0xFF5C6BC0), // Indigo 400
    ],
  ];

  List<Color> get currentColorSet => colorSets[_currentColorSetIndex];
  List<Color> get nextColorSet =>
      colorSets[(_currentColorSetIndex + 1) % colorSets.length];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentColorSetIndex =
              (_currentColorSetIndex + 1) % colorSets.length;
        });
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.slideAnimation,
      child: FadeTransition(
        opacity: widget.fadeAnimation,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: List.generate(
                    currentColorSet.length,
                    (index) =>
                        Color.lerp(
                          currentColorSet[index],
                          nextColorSet[index],
                          _animation.value,
                        )!,
                  ),
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
