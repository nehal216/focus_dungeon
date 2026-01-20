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
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "LOGIN",
          style: TextStyle(fontFamily: 'PixelFont'),
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

            /// LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () async {
                  try {
                    await AuthService().login(
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
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// FORGOT PASSWORD
            TextButton(
              onPressed: () {
                final resetController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF0B0E1A),
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
                                "Reset link sent",
                                style:
                                    TextStyle(fontFamily: 'PixelFont'),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "SEND",
                          style: TextStyle(
                            fontFamily: 'PixelFont',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
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
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PIXEL STYLE INPUT
  Widget _pixelField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontFamily: 'PixelFont',
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'PixelFont',
          color: Colors.white70,
        ),
        filled: true,
        fillColor: const Color(0xFF5A2DAA),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}
