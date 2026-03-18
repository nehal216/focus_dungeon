import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<void> login(String email, String password) async {
  await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw "unknown-error";
    }
  }

  // Logout (for later)
  Future<void> logout() async {
    await _auth.signOut();
  }
}

