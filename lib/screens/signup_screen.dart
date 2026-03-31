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
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        elevation: 0,
        title: const Text(
          "SIGN UP",
          style: TextStyle(fontFamily: 'VT323',
          fontSize: 22,
          letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// EMAIL FIELD
            _pixelField("EMAIL", emailController),

            const SizedBox(height: 16),

            /// PASSWORD FIELD
            _pixelField("PASSWORD", passwordController, obscure: true),

            const SizedBox(height: 30),

            /// SIGNUP BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 68, 5, 102),
                  side: const BorderSide(color: Colors.white, width: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
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
                          style: const TextStyle(fontFamily: 'VT323'),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PIXEL STYLE INPUT FIELD
  /// Builds a reusable text field with pixel art styling
  Widget _pixelField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontFamily: 'VT323',
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'VT323',
          color: Colors.white70,
        ),
        filled: true,
        fillColor: const Color(0xFF440566),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
            width: 3,
          ),
          borderRadius: BorderRadius.zero, // pixel look
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF4DEEFF),
            width: 3,
          ),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}

