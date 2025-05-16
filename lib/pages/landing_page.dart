import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/instrument_text.dart';
import '../utils/routes.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.1, 0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('images/wallpaper.png'),
                fit: BoxFit.cover,
                alignment: Alignment(_animation.value.dx, _animation.value.dy),
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
                          Navigator.pushNamed(context, DreamRoutes.loginRoute);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Signup button
                      _buildButton(
                        context: context,
                        text: 'Signup',
                        onPressed: () {
                          Navigator.pushNamed(context, DreamRoutes.signupRoute);
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
