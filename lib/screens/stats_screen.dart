import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        elevation: 0,
        title: const Text(
          "PLAYER STATS",
          style: TextStyle(
            fontFamily: 'VT323',
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
                  _statRow("LEVEL", data['level'].toString()),
                  _statRow("XP", data['xp'].toString()),
                  _statRow("COINS", data['coins'].toString()),
                  _statRow("STREAK", data['streak'].toString()),
                  _statRow("TOTAL FOCUS TIME", "${data['totalFocusTime']} mins"),
                  _statRow("SESSIONS COMPLETED", data['totalSessions'].toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// STAT ROW WIDGET
  /// Displays a stat row with pixel art styling
  Widget _statRow(String title, String value) {
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
}

