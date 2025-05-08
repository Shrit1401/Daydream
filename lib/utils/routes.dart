import 'package:daydream/pages/auth/login.dart';
import 'package:daydream/pages/auth/signup.dart';
import 'package:daydream/pages/home/home.dart';
import 'package:daydream/pages/note/note_page.dart';
import 'package:flutter/material.dart';

class DreamRoutes {
  static String loginRoute = "/login";
  static String signupRoute = "/signup";
  static String homeRoute = "/home";
  static String noteRoute = "/note";
}

final Map<String, Widget Function(BuildContext)> dreamRouters = {
  DreamRoutes.loginRoute: (context) => const LoginPage(),
  DreamRoutes.signupRoute: (context) => const SignupPage(),
  DreamRoutes.homeRoute: (context) => const HomePage(),
  DreamRoutes.noteRoute: (context) => const SingleNote(),
};
