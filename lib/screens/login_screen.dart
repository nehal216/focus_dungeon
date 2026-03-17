import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "LOGIN",
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
            _pixelField(
              "PASSWORD",
              passwordController,
              obscure: !_passwordVisible,
              isPassword: true,
              onVisibilityToggle: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),

            const SizedBox(height: 30),

            /// LOGIN BUTTON
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
                    // ignore: avoid_print
                    print("ACTUAL ERROR: $e");
                    String message = "Invalid email or password";

                    if (e is FirebaseAuthException) {
                      if (e.code == 'invalid-email') {
                        message = "Invalid email format";
                      } else if (e.code == 'too-many-requests') {
                        message = "Too many attempts. Try later";
                      } else {
                        message = "Invalid email or password";
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          message,
                          style: const TextStyle(fontFamily: 'VT323'),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: 20,
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
                    backgroundColor: const Color.fromARGB(255, 68, 5, 102),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.white, width: 3),
                      ),
                    title: const Text(
                      "RESET PASSWORD",
                      style: TextStyle(fontFamily: 'VT323',
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: Colors.white
                      ),
                    ),
                    content: TextField(
                      controller: resetController,
                      style: const TextStyle(fontFamily: 'VT323', color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "EMAIL",
                        labelStyle: const TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 18,
                          letterSpacing: 1.5,
                          color: Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF4DEEFF),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(0),
                        ),
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
                                    TextStyle(fontFamily: 'VT323'),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "SEND",
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 20,
                            letterSpacing: 1.5,
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
                  fontFamily: 'VT323',
                  fontSize: 20,
                  letterSpacing: 1.5,
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
                  fontFamily: 'VT323',
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: Colors.white,
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
    bool isPassword = false,
    VoidCallback? onVisibilityToggle,
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF4DEEFF),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
    );
  }
}

