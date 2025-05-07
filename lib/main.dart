import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

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

  void _setMode(int mode) {
    modeIndex = mode;
    setState(() {
      startTimeMs = defaultStartTimeMs[modeIndex].$1;
      timeLeftMs = defaultStartTimeMs[modeIndex].$1;
    });
    resetOnly();
    Navigator.pop(context);
  }

  void _showSheetUI() {
    showModalBottomSheet(
      context: context,
      builder:
          (cntx) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Pick your mode:",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                SizedBox(
                  height: 400,
                  child: ListWheelScrollView(
                    itemExtent: 64,
                    diameterRatio: 1.2,
                    children: [
                      //TODO Create mode Object with active state
                      SizedBox.expand(
                        child: InkWell(
                          onTap: () => _setMode(0),
                          child: Center(
                            child: Text("${defaultStartTimeMs[0].$2}"),
                          ),
                        ),
                      ),
                      SizedBox.expand(
                        child: InkWell(
                          onTap: () => _setMode(1),
                          child: Center(
                            child: Text("${defaultStartTimeMs[1].$2}"),
                          ),
                        ),
                      ),
                      SizedBox.expand(
                        child: InkWell(
                          onTap: () => _setMode(2),
                          child: Center(
                            child: Text("${defaultStartTimeMs[2].$2}"),
                          ),
                        ),
                      ),
                      SizedBox.expand(
                        child: InkWell(
                          onTap: () => _setMode(3),
                          child: Center(
                            child: Text("${defaultStartTimeMs[3].$2}"),
                          ),
                        ),
                      ),
                      SizedBox.expand(
                        child: InkWell(
                          onTap: () => _setMode(4),
                          child: Center(
                            child: Text("${defaultStartTimeMs[4].$2}"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    int seconds = (timeLeftMs ~/ 1000) % 60;
    int minutes = (timeLeftMs ~/ 60000);
    int millis = ((timeLeftMs % 1000) / 10).floor();

    return Scaffold(
      backgroundColor: bgcolor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          spacing: 8,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: resetAndStart,
                  onLongPress: resetOnly,
                  splashColor: const Color.fromARGB(75, 255, 255, 255),
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
            ),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: CupertinoButton(
                    color: Colors.white70,
                    onPressed: _showSheetUI,
                    child: Text(
                      defaultStartTimeMs[modeIndex].$2,
                      style: TextStyle(color: Colors.lightGreen[800]),
                    ),
                  ),
                ),
                CupertinoButton(
                  color: Colors.white70,
                  onPressed: _cycleMode, //TODO fullscreen method is missing
                  child: Icon(
                    Icons.swap_vert_rounded,
                    // Icons.open_in_full_rounded,
                    // Icons.volume_up_rounded,
                    color: Colors.lightGreen[800],
                  ),
                ),
                // IconButton.filled(
                //   onPressed: _showSheetUI,
                //   icon: Icon(Icons.style),
                //   tooltip: 'Cycle',
                //   style: IconButton.styleFrom(
                //     backgroundColor: Colors.white,
                //     foregroundColor: Colors.lightGreen[700],
                //     iconSize: 32,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
