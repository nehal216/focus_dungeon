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
    if (user == null) return;

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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0B0E1A),
                  title: const Text(
                    "LOG OUT?",
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Colors.white,
                    ),
                  ),
                  content: const Text(
                    "Are you sure you want to log out?",
                    style: TextStyle(
                      fontFamily: 'PixelFont',
                      color: Colors.white70,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(fontFamily: 'PixelFont'),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "LOG OUT",
                        style: TextStyle(
                          fontFamily: 'PixelFont',
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
Container(
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
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    },
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Text(
        "👤 VIEW PROFILE",
        style: TextStyle(
          fontFamily: 'PixelFont',
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    ),
  ),
),

            const SizedBox(height: 24),

            Row(
  children: [
    _statCard("LEVEL", data['level'], Icons.trending_up),
    _buildXpBar(
      currentXp: data['xp'],
      level: data['level'],
    ),
    _statCard("COINS", data['coins'], Icons.monetization_on),
  ],
),

            
            const SizedBox(height: 30),
            //DUNGEONS
            _buildDungeonButton("🟢 EASY DUNGEON", 60, 10, 5),
            _buildDungeonButton("🟡 MEDIUM DUNGEON", 180, 25, 15),
            _buildDungeonButton("🔴 HARD DUNGEON", 300, 50, 30),
            _buildCustomDungeonButton(),
          ],
        ),
      ),
    );
  }

  /// STAT CARD
  Widget _statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161A2D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF7B4DFF),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4DEEFF), size: 22),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 16,
                color: Color(0xFF4DEEFF),
              ),
            ),
            const SizedBox(height: 4),
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
  Widget _buildXpBar({
  required int currentXp,
  required int level,
}) {
  final maxXp = level * 50;
  final progress = currentXp / maxXp;

  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161A2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF7B4DFF),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "XP",
            style: TextStyle(
              fontFamily: 'PixelFont',
              fontSize: 10,
              color: Color(0xFFB0B0C3),
            ),
          ),
          const SizedBox(height: 6),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: Colors.black,
                    color: const Color(0xFF4DEEFF),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$currentXp / $maxXp",
                    style: const TextStyle(
                      fontFamily: 'PixelFont',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}


  /// DUNGEON BUTTON
  Widget _buildDungeonButton(
      String title, int duration, int xp, int coins) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1C1F3A),
          side: const BorderSide(color: Color(0xFF7B4DFF)),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DungeonScreen(
                dungeonName: title,
                duration: duration,
                xpReward: xp,
                coinReward: coins,
              ),
            ),
          );
          fetchUserData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'PixelFont',
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  /// CUSTOM SESSION BUTTON
  Widget _buildCustomDungeonButton() {
    final TextEditingController timeController = TextEditingController();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C896),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF0B0E1A),
              title: const Text(
                "CUSTOM SESSION",
                style: TextStyle(fontFamily: 'PixelFont',color: Colors.grey),
              ),
              content: TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontFamily: 'PixelFont',color: Colors.white,),
                decoration: const InputDecoration(
                  hintText: "Enter time in minutes",
                  hintStyle: TextStyle(fontFamily: 'PixelFont',color: Colors.grey,),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(fontFamily: 'PixelFont'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final minutes = int.tryParse(timeController.text);

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
                    style: TextStyle(fontFamily: 'PixelFont'),
                  ),
                ),
              ],
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Text(
            "⚡ CUSTOM SESSION",
            style: TextStyle(
              fontFamily: 'PixelFont',
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
