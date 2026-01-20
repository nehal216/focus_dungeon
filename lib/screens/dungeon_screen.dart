import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DungeonScreen extends StatefulWidget {
  final String dungeonName;
  final int duration;
  final int xpReward;
  final int coinReward;

  const DungeonScreen({
    super.key,
    required this.dungeonName,
    required this.duration,
    required this.xpReward,
    required this.coinReward,
  });

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  late int secondsLeft;
  Timer? timer;
  bool isRunning = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.duration;
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  void startDungeon() {
    setState(() {
      isRunning = true;
      isPaused = false;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isPaused) {
        if (secondsLeft == 0) {
          t.cancel();
          completeDungeon();
        } else {
          setState(() {
            secondsLeft--;
          });
        }
      }
    });
  }

  void pauseDungeon() {
    setState(() {
      isPaused = true;
    });
  }

  void resumeDungeon() {
    setState(() {
      isPaused = false;
    });
  }

  void stopDungeon() {
    timer?.cancel();
    Navigator.pop(context);
  }

  Future<void> completeDungeon() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      int currentXp = snapshot['xp'];
      int currentLevel = snapshot['level'];
      int currentCoins = snapshot['coins'];

      int newXp = currentXp + widget.xpReward;
      int requiredXp = currentLevel * 50;

      if (newXp >= requiredXp) {
        newXp -= requiredXp;
        currentLevel++;
      }

      transaction.update(docRef, {
        'xp': newXp,
        'level': currentLevel,
        'coins': currentCoins + widget.coinReward,
        'totalFocusTime': FieldValue.increment(widget.duration ~/ 60),
        'totalSessions': FieldValue.increment(1),
      });
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B0E1A),
        title: const Text(
          "DUNGEON CLEARED!",
          style: TextStyle(fontFamily: 'PixelFont', color: Colors.white),
        ),
        content: Text(
          "You earned ${widget.xpReward} XP\nand ${widget.coinReward} Coins!",
          style: const TextStyle(
            fontFamily: 'PixelFont',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "RETURN",
              style: TextStyle(fontFamily: 'PixelFont'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dungeonName,
          style: const TextStyle(
            fontFamily: 'PixelFont',
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

            const Text(
              "TIME REMAINING",
              style: TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 16),

            /// TIMER
            Text(
              formatTime(secondsLeft),
              style: const TextStyle(
                fontFamily: 'PixelFont',
                fontSize: 44,
                color: Color(0xFF4DEEFF),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 40),

            /// BUTTONS
            if (!isRunning)
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: startDungeon,
                  child: const Text(
                    "START SESSION",
                    style: TextStyle(fontFamily: 'PixelFont'),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isPaused ? resumeDungeon : pauseDungeon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(
                        isPaused ? "RESUME" : "PAUSE",
                        style: const TextStyle(fontFamily: 'PixelFont'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: stopDungeon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "STOP",
                        style: TextStyle(fontFamily: 'PixelFont'),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
