import 'package:daydream/components/instrument_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  late SharedPreferences _prefs;

  final List<Map<String, dynamic>> _onboardingContent = [
    {
      'title': 'yo.',
      'description':
          'not another generic app. your space to reflect, dream, and actually build the life you want. lets goooo.',
      'hasImage': false,
    },
    {
      'title': 'i\'m shrit.',
      'description':
          'been journaling for a while now. built this to help you find clarity, just like i did. it\'s raw, real, and yours.',
      'hasImage': true,
      'image': 'images/me.png',
    },
    {
      'title': 'magic fix?',
      'description':
          'hell no. but it\'ll help you understand your own brain better. and when you do that? you start making real moves.',
      'hasImage': false,
    },
    {
      'title': 'one more thing',
      'description': 'you gotta show up and write. it\'s worth it.',
      'hasImage': false,
    },
    {
      'title': 'ready to start?',
      'description':
          'let\'s begin your journey. start documenting your dreams today.',
      'hasImage': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < _onboardingContent.length - 1) {
      _controller.forward().then((_) {
        setState(() {
          _currentPage++;
        });
        _controller.reverse();
      });
    } else {
      try {
        await _prefs.setBool('onboarded_home', true);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/landing');
      } catch (e) {
        debugPrint('Error saving onboarding status: $e');
        // Still navigate even if saving fails
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_onboardingContent[_currentPage]['hasImage'] == true)
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  _onboardingContent[_currentPage]['image']!,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      if (_onboardingContent[_currentPage]['hasImage'] == true)
                        const SizedBox(height: 40),
                      InstrumentText(
                        _onboardingContent[_currentPage]['title']!,
                        fontSize: 42,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _onboardingContent[_currentPage]['description']!,
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.white70,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _nextPage,
                  icon: Icon(
                    _currentPage < _onboardingContent.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
