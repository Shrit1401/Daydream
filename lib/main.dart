import 'package:daydream/utils/routes.dart';
import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          surface: const Color(0xFFF3F1EF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F1EF),
        fontFamily: 'serif',
      ),
      initialRoute: DreamRoutes.landingRoute,
      routes: dreamRouters,
    );
  }
}
