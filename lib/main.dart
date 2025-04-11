import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(NotimeApp());
}

class NotimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'No Time',
      home: MainUI(),
    );
  }
}

class MainUI extends StatefulWidget {
  @override
  State<MainUI> createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  static const int startTimeMs = 90 * 1000; // 1 min 30 sec
  int timeLeftMs = startTimeMs;
  Timer? timer;

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 10), (t) {
      if (timeLeftMs <= 0) {
        t.cancel();
        setState(() {
          timeLeftMs = 0;
        });
      } else {
        setState(() {
          timeLeftMs -= 10;
        });
      }
    });
  }

  void resetAndStart() {
    setState(() {
      timeLeftMs = startTimeMs;
    });
    startTimer();
  }

  void resetOnly() {
    timer?.cancel();
    setState(() {
      timeLeftMs = startTimeMs;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int seconds = (timeLeftMs ~/ 1000) % 60;
    int minutes = (timeLeftMs ~/ 60000);
    int millis = ((timeLeftMs % 1000) / 10).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text('No Time', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.lightGreen,
      body: GestureDetector(
  onTap: resetAndStart,
  onLongPress: resetOnly,
  behavior: HitTestBehavior.opaque, // ensures tap events go through empty areas
  child: Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.lightGreen, // this can be transparent if you prefer
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          minutes > 0
              ? '${minutes.toString().padLeft(2, '0')}'
              : '${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.white, fontSize: 96, fontWeight: FontWeight.w900),
        ),
        Text(
          minutes > 0
              ? '${seconds.toString().padLeft(2, '0')}.${(millis ~/ 10)}'
              : '.${millis.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.white70, fontSize: 56, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  ),
),
    );
  }
}
