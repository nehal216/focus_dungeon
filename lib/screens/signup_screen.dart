import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      appBar: AppBar(
        title: const Text(
          "CREATE ACCOUNT",
          style: TextStyle(
            fontFamily: 'PixelFont',
            fontSize: 14,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// EMAIL
            TextField(
              controller: emailController,
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: "EMAIL",
                labelStyle: const TextStyle(
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
            ),

            const SizedBox(height: 16),

            /// PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.white,
              ),
              decoration: InputDecoration(
                labelText: "PASSWORD",
                labelStyle: const TextStyle(
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
            ),

            const SizedBox(height: 30),

            /// SIGNUP BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4DFF),
                ),
                onPressed: () async {
                  final authService = AuthService();
                  final firestoreService = FirestoreService();

                  try {
                    final user = await authService.signUp(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    if (user != null) {
                      await firestoreService.createUserProfile(
                        uid: user.uid,
                        email: user.email ?? '',
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString(),
                          style: const TextStyle(fontFamily: 'PixelFont'),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 12,
                    letterSpacing: 1.2,
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