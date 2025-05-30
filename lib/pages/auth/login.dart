import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/common/instrument_text.dart';
import '../../utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/authWallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Title
                      Column(
                        children: [
                          InstrumentText.title('Dream.'),
                          Text(
                            'welcome back, storyteller',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Email field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _isObscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Navigate to forgot password screen
                          },
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: InstrumentText.button(
                            _isLoading ? 'Loading' : 'Login',
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // OR divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.withValues(
                                red: 128,
                                green: 128,
                                blue: 128,
                                alpha: 128,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.withValues(
                                red: 128,
                                green: 128,
                                blue: 128,
                                alpha: 128,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Google Login button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            backgroundColor: Colors.white.withValues(
                              red: 255,
                              green: 255,
                              blue: 255,
                              alpha: 230,
                            ),
                          ),
                          icon: Image.asset(
                            'images/google.png',
                            height: 24.0,
                            width: 24.0,
                          ),
                          label: Text(
                            'Sign in with Google',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Create account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                DreamRoutes.signupRoute,
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Sign in with email and password
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back Storyteller!',
                style: GoogleFonts.dmSans(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to home page
          Navigator.pushReplacementNamed(context, DreamRoutes.homeRoute);
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found with this email.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided.';
            break;
          case 'invalid-email':
            message = 'Invalid email address.';
            break;
          case 'user-disabled':
            message = 'This account has been disabled.';
            break;
          default:
            message = "Wrong email or password";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        // Handle generic errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${e.toString()}',
                style: GoogleFonts.dmSans(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in not made by me hehe!')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(color: Colors.black54),
        prefixIcon: Icon(prefixIcon, color: Colors.black54),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.white.withValues(
          red: 255,
          green: 255,
          blue: 255,
          alpha: 204,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: validator,
    );
  }
}
