import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/instrument_text.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // App title
                  InstrumentText.title('Daydream'),
                  // Subtitle
                  Text(
                    'a story journal',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(flex: 10),
                  // Login button
                  _buildButton(
                    context: context,
                    text: 'Login',
                    onPressed: () {
                      // Add login functionality
                    },
                  ),
                  const SizedBox(height: 16),
                  // Signup button
                  _buildButton(
                    context: context,
                    text: 'Signup',
                    onPressed: () {
                      // Add signup functionality
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: InstrumentText.button(text),
      ),
    );
  }
}
