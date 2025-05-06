import 'package:flutter/material.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(const DaydreamApp());
}

class DaydreamApp extends StatelessWidget {
  const DaydreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daydream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        fontFamily: 'serif',
      ),
      home: const LandingPage(),
    );
  }
}
