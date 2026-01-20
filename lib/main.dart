import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: false,

        /// GLOBAL BACKGROUND
        scaffoldBackgroundColor: const Color(0xFF0B0E1A),

        /// GLOBAL FONT
        fontFamily: 'PixelFont',

        /// APP BAR THEME
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0E1A),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 14,
            color: Colors.white,
          ),
        ),

        /// INPUT FIELDS (Login / Signup)
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            fontFamily: 'PixelFont',
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
        ),

        /// BUTTON STYLE
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B4DFF),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 12,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        /// TEXT DEFAULTS
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'PixelFont',
            color: Colors.white,
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}