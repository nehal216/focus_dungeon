import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dungeon_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

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
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _showMenu,
        ),
        title: const Text(
          "FOCUS DUNGEON",
          style: TextStyle(
            fontFamily: 'PixelFont',
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Text(
              "WELCOME BACK, ${(data['username'] ?? 'PLAYER').toUpperCase()}",
              style: const TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 20,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            /// STATS ICONS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statIcon("🔥", "${data['streak'] ?? 0}", "STREAK"),
                _statIcon("🪙", "${data['coins'] ?? 0}", "COINS"),
                _statIcon("⭐", "${data['xp'] ?? 0}", "XP"),
                _statIcon("🎖️", "${data['level'] ?? 1}", "LEVEL"),
              ],
            ),

            const SizedBox(height: 20),

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

  /// STAT ICON WIDGET
  /// Displays a stat with icon, value and label in a pixel-styled box
  Widget _statIcon(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF440566),
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Color(0xFF4DEEFF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.white70,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PIXEL STYLE BUTTON
  /// Builds a reusable pixel-styled button with consistent theming
  Widget _pixelButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 68, 5, 102),
          side: const BorderSide(color: Colors.white, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// CUSTOM SESSION BUTTON
  /// Opens a dialog to create a custom focus session
  Widget _customSessionButton() {
    final controller = TextEditingController();

    return _pixelButton("⚡ CUSTOM SESSION", () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 68, 5, 102),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Colors.white, width: 3),
          ),
          title: const Text("CUSTOM SESSION",
              style: TextStyle(fontFamily: 'PixelFont',color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'PixelFont', color: Colors.white),
            decoration: InputDecoration(
              hintText: "Minutes",
              hintStyle: const TextStyle(
                fontFamily: 'PixelFont',
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
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
              ),
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
              child: const Text(
                "START",
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// MENU POPUP
  /// Shows menu with Profile and Logout options
  void _showMenu() {
    showMenu<void>(
      context: context,
      position: const RelativeRect.fromLTRB(0, 56, 0, 0),
      color: const Color(0xFF440566),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      items: [
        PopupMenuItem<void>(
          child: const Text(
            "PROFILE",
            style: TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<void>(
          child: const Text(
            "VIEW STATS",
            style: TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            );
          },
        ),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<void>(
          onTap: _logout,
          child: const Text(
            "LOG OUT",
            style: TextStyle(
              fontFamily: 'PixelFont',
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
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

  /// LOGOUT CONFIRMATION
  /// Shows a dialog to confirm logout action
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        title: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            fontSize:16,
            fontFamily: 'PixelFont',
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.white,
              ),
            ),
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
            child: const Text(
              "LOG OUT",
              style: TextStyle(
                fontFamily: 'PixelFont',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
