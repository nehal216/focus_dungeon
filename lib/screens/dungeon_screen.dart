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
        backgroundColor: const Color.fromARGB(255, 68, 5, 102),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: Colors.white, width: 3),
        ),
        title: const Text(
          "DUNGEON CLEARED!",
          style: TextStyle(fontFamily: 'VT323', 
          fontSize: 22,
          letterSpacing: 1.5,
          color: Colors.white),
        ),
        content: Text(
          "You earned ${widget.xpReward} XP\nand ${widget.coinReward} Coins!",
          style: const TextStyle(
            fontFamily: 'VT323',
            fontSize: 20,
            letterSpacing: 1.5,
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6F2DBD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.dungeonName,
          style: const TextStyle(fontFamily: 'VT323'),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "TIME REMAINING",
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 20),
            /// TIMER
            Text(
              formatTime(secondsLeft),
              style: const TextStyle(
                fontFamily: 'VT323',
                fontSize: 80,
                color: Color(0xFF4DEEFF),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            /// BUTTONS
            if (!isRunning)
              SizedBox(
                width: 240,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF440566),
                    side: const BorderSide(color: Colors.white, width: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: startDungeon,
                  child: const Text(
                    "START SESSION",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 20,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isPaused ? resumeDungeon : pauseDungeon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.white, width: 3),
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),),
                      child: Text(
                        isPaused ? "RESUME" : "PAUSE",
                        style: const TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 20,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 130,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: stopDungeon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.white, width: 3),
                        shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                      ),
                      child: const Text(
                        "STOP",
                        style: TextStyle(
                          fontFamily: 'VT323',
                          fontSize: 20,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
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

