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

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileRow("EMAIL", data['email'] ?? "Not set", false),
                  _profileRow("USERNAME", data['username'] ?? "Not set", true, user.uid),
                  _profileRow("PHONE", data['phone'] ?? "Not set", true, user.uid),
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
                value,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: Color(0xFF4DEEFF),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            )
          else
            Text(
              value,
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
    final controller = TextEditingController(text: currentValue);
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
          style: const TextStyle(fontFamily: 'VT323',fontSize:20,color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'VT323', color: Colors.white),
          decoration: InputDecoration(
            hintText: fieldName,
            hintStyle: const TextStyle(
              fontFamily: 'VT323',
              color: Colors.white70,
            ),
            filled: true,
            fillColor: const Color(0xFF440566),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF4DEEFF),
                width: 2,
              ),
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
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({fieldKey: controller.text});

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
}

// FutureBuilder(
//   future: FirebaseFirestore.instance
//       .collection('users')
//       .doc(user!.uid)
//       .get(),