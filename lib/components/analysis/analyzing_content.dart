import 'package:flutter/material.dart';
import 'package:daydream/components/instrument_text.dart';

class AnalyzingContent extends StatelessWidget {
  final Animation<Color?> textColorAnimation;

  const AnalyzingContent({super.key, required this.textColorAnimation});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        InstrumentText(
          "Analyzing ysour story...",
          fontSize: 36,
          color: textColorAnimation.value ?? Colors.black,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
