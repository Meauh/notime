import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(NotimeApp());
}

class NotimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'No Time', home: MainUI());
  }
}

class MainUI extends StatefulWidget {
  @override
  State<MainUI> createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  final AudioPlayer player = AudioPlayer();

  static const List<(int, String)> defaultStartTimeMs = [
    (65 * 1000, "Normal"),
    (1500 * 1000, "Pomodoro"),
    (5 * 1000, "Swift"),
    (30 * 1000, "Fast"),
    (150 * 1000, "Slow"),
  ];
  int startTimeMs = defaultStartTimeMs[0].$1;
  int timeLeftMs = defaultStartTimeMs[0].$1;
  int modeIndex = 0;
  Timer? timer;
  Color bgdefault = Colors.lightGreen;
  Color bgcolor = Colors.lightGreen;

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: 10), (t) {
      if (timeLeftMs <= 0) {
        player.play(AssetSource('audio/alarm_sound.wav'));
        t.cancel();
        setState(() {
          timeLeftMs = 0;
          bgcolor = Colors.redAccent;
        });
      } else {
        setState(() {
          timeLeftMs -= 10;
        });
      }
    });
  }

  void resetAndStart() {
    player.play(AssetSource('audio/click_sound.wav'));
    setState(() {
      timeLeftMs = startTimeMs;
      bgcolor = bgdefault;
    });
    startTimer();
  }

  void resetOnly() {
    timer?.cancel();
    setState(() {
      timeLeftMs = startTimeMs;
      bgcolor = bgdefault;
    });
  }

  void _cycleMode() {
    modeIndex++;
    if (modeIndex >= defaultStartTimeMs.length) {
      modeIndex = 0;
    }
    setState(() {
      startTimeMs = defaultStartTimeMs[modeIndex].$1;
      timeLeftMs = defaultStartTimeMs[modeIndex].$1;
    });
    resetOnly();
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
      backgroundColor: bgcolor,
      body: GestureDetector(
        onTap: resetAndStart,
        onLongPress: resetOnly,
        behavior:
            HitTestBehavior.opaque, // ensures tap events go through empty areas
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent, // this can be transparent if you prefer
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                minutes > 0
                    ? '${minutes.toString().padLeft(2, '0')}'
                    : '${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                minutes > 0
                    ? '${seconds.toString().padLeft(2, '0')}.${(millis ~/ 10)}'
                    : '.${millis.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
      
      persistentFooterButtons: [
        Row(
          children: [
            Spacer(),
              Text(
                defaultStartTimeMs[modeIndex].$2,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
            ),
            Spacer(),
            IconButton.filled(
              onPressed: _cycleMode,
              icon: Icon(Icons.style),
              tooltip: 'Cycle',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.lightGreen[700],
                iconSize: 32,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
