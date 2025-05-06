import 'package:daydream/pages/auth/login.dart';
import 'package:daydream/pages/auth/signup.dart';
import 'package:daydream/pages/landing_page.dart';
import 'package:daydream/pages/home/home.dart';
import 'package:flutter/material.dart';

class DreamRoutes {
  static String landingRoute = "/";
  static String loginRoute = "/login";
  static String signupRoute = "/signup";
  static String homeRoute = "/home";
}

final Map<String, Widget Function(BuildContext)> dreamRouters = {
  DreamRoutes.landingRoute: (context) => const LandingPage(),
  DreamRoutes.loginRoute: (context) => const LoginPage(),
  DreamRoutes.signupRoute: (context) => const SignupPage(),
  DreamRoutes.homeRoute: (context) => const HomePage(),
};
