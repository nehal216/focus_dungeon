import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PLAYER PROFILE",
          style: TextStyle(fontFamily: 'PixelFont'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileRow("EMAIL", data['email']),
                _profileRow("LEVEL", data['level'].toString()),
                _profileRow("XP", data['xp'].toString()),
                _profileRow("COINS", data['coins'].toString()),
                _profileRow(
                  "TOTAL FOCUS TIME",
                  "${data['totalFocusTime']} mins",
                ),
                _profileRow(
                  "SESSIONS COMPLETED",
                  data['totalSessions'].toString(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7B4DFF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PixelFont',
              color: Color(0xFF4DEEFF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
