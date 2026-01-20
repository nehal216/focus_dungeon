import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      appBar: AppBar(
        title: const Text(
          "LOGIN",
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

            /// LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4DFF),
                ),
                onPressed: () async {
                  final authService = AuthService();

                  try {
                    await authService.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );

                    if (!context.mounted) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
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
                  "LOGIN",
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// FORGOT PASSWORD
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final resetController = TextEditingController();

                    return AlertDialog(
                      title: const Text(
                        "RESET PASSWORD",
                        style: TextStyle(fontFamily: 'PixelFont'),
                      ),
                      content: TextField(
                        controller: resetController,
                        style: const TextStyle(fontFamily: 'PixelFont'),
                        decoration: const InputDecoration(
                          hintText: "Enter your email",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await AuthService()
                                .resetPassword(resetController.text.trim());

                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Reset link sent to email",
                                  style:
                                      TextStyle(fontFamily: 'PixelFont'),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "SEND",
                            style: TextStyle(fontFamily: 'PixelFont'),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(fontFamily: 'PixelFont'),
              ),
            ),

            /// SIGN UP
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              child: const Text(
                "Don't have an account? Sign up",
                style: TextStyle(fontFamily: 'PixelFont'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}