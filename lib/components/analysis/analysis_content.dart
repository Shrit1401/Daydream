import 'package:flutter/material.dart';
import 'package:daydream/components/analysis/reveal_content.dart';
import 'package:daydream/components/analysis/analyzing_content.dart';

class AnalysisContent extends StatelessWidget {
  final bool hasStarted;
  final Animation<Color?> textColorAnimation;
  final VoidCallback onStartAnalysis;

  const AnalysisContent({
    super.key,
    required this.hasStarted,
    required this.textColorAnimation,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          hasStarted
              ? AnalyzingContent(textColorAnimation: textColorAnimation)
              : RevealContent(
                textColorAnimation: textColorAnimation,
                onStartAnalysis: onStartAnalysis,
              ),
    );
  }
}
