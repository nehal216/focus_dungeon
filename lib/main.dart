import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

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
        fontFamily: 'VT323',

        /// APP BAR THEME
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0E1A),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'VT323',
            fontSize: 16,
            color: Colors.white,
          ),
        ),

        /// INPUT FIELDS (Login / Signup)
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            fontFamily: 'VT323',
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
              fontFamily: 'VT323',
              fontSize: 14,
              letterSpacing: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        /// TEXT DEFAULTS
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'VT323',
            color: Colors.white,
          ),
        ),
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}