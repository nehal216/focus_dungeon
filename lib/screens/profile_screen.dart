import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        elevation: 0,
        title: const Text(
          "PLAYER PROFILE",
          style: TextStyle(fontFamily: 'VT323',
          fontSize: 22,
          letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final username = (data['username'] ?? '').toString().trim();
          final phone = (data['phone'] ?? '').toString().trim();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileRow("EMAIL", data['email'] ?? "Not set", false),
                  _profileRow("USERNAME", username, true, user.uid),
                  _profileRow("PHONE", phone, true, user.uid),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade900,
                        side: const BorderSide(color: Colors.red, width: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () => _deleteAccount(context, user.uid),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          "DELETE ACCOUNT",
                          style: TextStyle(
                            fontFamily: 'VT323',
                            fontSize: 22,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// PROFILE ROW WIDGET
  /// Displays a profile info row with optional editing capability
  Widget _profileRow(
    String title,
    String value,
    bool isEditable, [
    String? uid,
  ]) {
    final isEmpty = value.isEmpty;
    final displayText = isEmpty ? "TAP TO SET" : value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF440566),
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'VT323',
              fontSize: 20,
              letterSpacing: 1.5,
              color: Colors.white70,
            ),
          ),
          if (isEditable)
            GestureDetector(
              onTap: () => _editField(title, value, uid!),
              child: Text(
                displayText,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: isEmpty ? Colors.white38 : const Color(0xFF4DEEFF),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              displayText,
              style: const TextStyle(
                fontFamily: 'VT323',
                fontSize: 20,
                letterSpacing: 1.5,
                color: Color(0xFF4DEEFF),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  /// EDIT FIELD DIALOG
  /// Allows editing of username and phone number
  void _editField(String fieldName, String currentValue, String uid) {
    final controller = TextEditingController(
      text: currentValue.isEmpty ? '' : currentValue,
    );
    final fieldKey = fieldName.toLowerCase();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        title: Text(
          "EDIT $fieldName",
          style: const TextStyle(fontFamily: 'VT323', fontSize: 20, color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'VT323', color: Colors.white),
          keyboardType: fieldName == "PHONE"
              ? TextInputType.phone
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: "Enter $fieldName",
            hintStyle: const TextStyle(
              fontFamily: 'VT323',
              color: Colors.white38,
            ),
            filled: true,
            fillColor: const Color(0xFF440566),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4DEEFF), width: 2),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({fieldKey: newValue});

              if (!context.mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text(
              "SAVE",
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
  }

  void _deleteAccount(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF440566),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        title: const Text(
          "DELETE ACCOUNT?",
          style: TextStyle(
            fontFamily: 'VT323',
            fontSize: 22,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        content: const Text(
          "This will permanently delete your account and all data. This cannot be undone!",
          style: TextStyle(
            fontFamily: 'VT323',
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .delete();

                await FirebaseAuth.instance.currentUser!.delete();

                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().contains('requires-recent-login')
                          ? "Please log out and log back in before deleting."
                          : e.toString(),
                      style: const TextStyle(fontFamily: 'VT323'),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              "DELETE",
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}