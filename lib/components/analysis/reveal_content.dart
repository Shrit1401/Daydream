import 'package:flutter/material.dart';
import 'package:daydream/components/instrument_text.dart';
import 'package:daydream/components/analysis/start_analysis_button.dart';

class RevealContent extends StatelessWidget {
  final Animation<Color?> textColorAnimation;
  final VoidCallback onStartAnalysis;

  const RevealContent({
    super.key,
    required this.textColorAnimation,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        InstrumentText(
          "Ready to reveal your story?",
          fontSize: 36,
          color: textColorAnimation.value ?? Colors.black,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        StartAnalysisButton(onPressed: onStartAnalysis),
      ],
    );
  }
}
