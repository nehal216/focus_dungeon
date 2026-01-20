import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dungeon_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      userData = doc;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = userData!.data() as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      appBar: AppBar(
        title: const Text(
          "FOCUS DUNGEON",
          style: TextStyle(
            fontFamily: 'PixelFont',
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            const Text(
              "WELCOME BACK",
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['email'],
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            /// PROFILE BUTTON
            _pixelButton(
              "👤 VIEW PROFILE",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),

            const SizedBox(height: 20),

            /// STATS
            Row(
              children: [
                _statCard("LEVEL", data['level'], Icons.trending_up),
                _xpBar(data['xp'], data['level']),
                _statCard("COINS", data['coins'], Icons.monetization_on),
              ],
            ),

            const SizedBox(height: 28),

            /// DUNGEONS
            _pixelButton("🟢 EASY DUNGEON", () => _startDungeon(60, 10, 5)),
            _pixelButton("🟡 MEDIUM DUNGEON", () => _startDungeon(180, 25, 15)),
            _pixelButton("🔴 HARD DUNGEON", () => _startDungeon(300, 50, 30)),
            _customSessionButton(),
          ],
        ),
      ),
    );
  }

  // ───────────────────── WIDGETS ─────────────────────

  Widget _pixelButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C1F3A),
          side: const BorderSide(color: Color(0xFF7B4DFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'PixelFont',
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161A2D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF7B4DFF), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4DEEFF)),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Color(0xFF4DEEFF),
                fontSize: 16,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 10,
                color: Color(0xFFB0B0C3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xpBar(int xp, int level) {
    final maxXp = level * 50;
    final progress = xp / maxXp;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161A2D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF7B4DFF), width: 2),
        ),
        child: Column(
          children: [
            const Text("XP",
                style: TextStyle(fontFamily: 'PixelFont', fontSize: 10)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black,
              color: const Color(0xFF4DEEFF),
            ),
            const SizedBox(height: 6),
            Text(
              "$xp / $maxXp",
              style: const TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customSessionButton() {
    final controller = TextEditingController();

    return _pixelButton("⚡ CUSTOM SESSION", () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0B0E1A),
          title: const Text("CUSTOM SESSION",
              style: TextStyle(fontFamily: 'PixelFont')),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'PixelFont'),
            decoration: const InputDecoration(
              hintText: "Minutes",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL",
                  style: TextStyle(fontFamily: 'PixelFont')),
            ),
            TextButton(
              onPressed: () {
                final minutes = int.tryParse(controller.text);
                if (minutes == null || minutes <= 0) return;

                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DungeonScreen(
                      dungeonName: "Custom Session",
                      duration: minutes * 60,
                      xpReward: minutes * 2,
                      coinReward: minutes,
                    ),
                  ),
                );
              },
              child:
                  const Text("START", style: TextStyle(fontFamily: 'PixelFont')),
            ),
          ],
        ),
      );
    });
  }

  void _startDungeon(int time, int xp, int coins) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DungeonScreen(
          dungeonName: "Dungeon",
          duration: time,
          xpReward: xp,
          coinReward: coins,
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B0E1A),
        title:
            const Text("LOG OUT?", style: TextStyle(fontFamily: 'PixelFont')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("CANCEL", style: TextStyle(fontFamily: 'PixelFont')),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("LOG OUT",
                style: TextStyle(fontFamily: 'PixelFont', color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
