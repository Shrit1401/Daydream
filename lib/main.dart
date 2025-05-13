import 'package:daydream/pages/home/home.dart';
import 'package:daydream/pages/landing_page.dart';
import 'package:daydream/utils/firebase/firebase_options.dart';
import 'package:daydream/utils/hive/database_service.dart';
import 'package:daydream/utils/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:daydream/components/dream_bubble_loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseService.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
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
          seedColor: const Color.fromARGB(255, 32, 20, 63),
          surface: const Color(0xFFF3F1EF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F1EF),
        fontFamily: 'serif',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: DreamBubbleLoading(
                  title: 'Loading your dreams...',
                  subtitle: 'Preparing your personal space',
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomePage();
          }

          return const LandingPage();
        },
      ),
      routes: dreamRouters,
      navigatorObservers: [routeObserver],
    );
  }
}
