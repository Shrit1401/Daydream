import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class DreamBubbleLoading extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String imagePath;
  const DreamBubbleLoading({
    super.key,
    this.title,
    this.subtitle,
    this.imagePath = 'images/loading.png',
  });

  @override
  State<DreamBubbleLoading> createState() => _DreamBubbleLoadingState();
}

class _DreamBubbleLoadingState extends State<DreamBubbleLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_animation.value),
              child: child,
            );
          },
          child: SizedBox(
            width: 90,
            height: 90,
            child: Center(
              child: Image.asset(widget.imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          widget.title ?? 'Preparing your story...',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.subtitle ?? 'Weaving your daydreams \n and setting the mood.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black54),
        ),
      ],
    );
  }
}
