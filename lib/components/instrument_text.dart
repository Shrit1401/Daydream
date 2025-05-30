import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InstrumentText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool italic;
  final TextAlign textAlign;

  const InstrumentText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.italic = true,
    this.textAlign = TextAlign.center,
  });

  // Factory constructor for large title style
  factory InstrumentText.title(
    String text, {
    Key? key,
    Color color = Colors.black,
  }) {
    return InstrumentText(
      text,
      key: key,
      fontSize: 70,
      color: color,
      fontWeight: FontWeight.w800,
      italic: true,
    );
  }

  // Factory constructor for button text style
  factory InstrumentText.button(
    String text, {
    Key? key,
    Color color = Colors.white,
  }) {
    return InstrumentText(
      text,
      key: key,
      fontSize: 22,
      color: color,
      fontWeight: FontWeight.w800,
      italic: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.instrumentSerif(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}
