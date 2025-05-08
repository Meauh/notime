import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
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

class _MainUIState extends State<MainUI> with SingleTickerProviderStateMixin {
  // Global
  final AudioPlayer player = AudioPlayer();

  // Logic var
  final List<Mode> modes = [
    Mode(label: "Normal", startTimeMs: 65 * 1000),
    Mode(label: "Pomodoro", startTimeMs: 1500 * 1000),
    Mode(label: "Swift", startTimeMs: 5 * 1000),
    Mode(label: "Fast", startTimeMs: 30 * 1000),
    Mode(label: "Slow", startTimeMs: 150 * 1000),
  ];
  late int startTimeMs;
  late int timeLeftMs;
  int modeIndex = 0;
  Timer? timer;

  // UI var
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _rowSlideAnimation;
  late Animation<double> _fadeAnimation;
  Color bgdefault = Color.fromRGBO(124, 179, 66, 1);
  Color bgcolor = Color.fromRGBO(124, 179, 66, 1);
  String appBarDefaultLabel = "to start!";
  String appBarLabel = "to start!";
  bool _visible = true;
  double spacer = 8;

  @override
  void initState() {
    super.initState();
    startTimeMs = modes[0].startTimeMs;
    timeLeftMs = startTimeMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rowSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int seconds = (timeLeftMs ~/ 1000) % 60;
    int minutes = (timeLeftMs ~/ 60000);
    int millis = ((timeLeftMs % 1000) / 10).floor();

    return Scaffold(
      extendBodyBehindAppBar: !_visible,
      appBar: SlidingAppBar(
        controller: _controller,
        child: AppBar(
          backgroundColor: const Color.fromARGB(25, 0, 0, 0),
          elevation: 0,
          title: Text(
            "No time $appBarLabel",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            // IconButton(onPressed: () {},icon: Icon(Icons.volume_up_rounded, color: Colors.white),),
          ],
        ),
      ),
      backgroundColor: bgcolor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(spacer),
        child: Column(
          spacing: 8,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(spacer * 2),
                  onTap: resetAndStart,
                  onLongPress: resetOnly,
                  splashColor: const Color.fromARGB(75, 255, 255, 255),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Center(
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
                        Positioned(
                          top: 8,
                          right: 0,
                          child: IconButton(
                            onPressed: _toggleFullscreen,
                            icon:
                                _visible
                                    ? Icon(
                                      Icons.open_in_full_rounded,
                                      color: Colors.white,
                                    )
                                    : Icon(
                                      Icons.close_fullscreen_rounded,
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            (_visible)
                ? SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: Color.fromARGB(25, 0, 0, 0),
                            onPressed: _showSheetUI,
                            child: Text(
                              "${modes[modeIndex].label} (${(modes[modeIndex].startTimeMs / 1000) ~/ 60}:${(((modes[modeIndex].startTimeMs / 1000) % 60).toInt()).toString().padLeft(2, '0')})",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        CupertinoButton(
                          color: Color.fromARGB(25, 0, 0, 0),
                          onPressed: _cycleMode,
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void startTimer() {
    timer?.cancel();
    appBarLabel = "to waste";
    timer = Timer.periodic(Duration(milliseconds: 10), (t) {
      if (timeLeftMs <= 0) {
        player.play(AssetSource('audio/alarm_sound.wav'));
        t.cancel();
        setState(() {
          timeLeftMs = 0;
          bgcolor = Colors.redAccent;
          appBarLabel = "left.";
        });
      } else {
        setState(() {
          timeLeftMs -= 10;
        });
      }
    });
  }

  void resetAndStart() async {
    await player.play(AssetSource('audio/click_sound.wav'));
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
      appBarLabel = "to start!";
    });
  }

  void _cycleMode() {
    resetOnly();
    modeIndex++;
    if (modeIndex >= modes.length) {
      modeIndex = 0;
    }
    setState(() {
      startTimeMs = modes[modeIndex].startTimeMs;
      timeLeftMs = modes[modeIndex].startTimeMs;
    });
  }

  void _setMode(int mode) {
    modeIndex = mode;
    setState(() {
      startTimeMs = modes[modeIndex].startTimeMs;
      timeLeftMs = modes[modeIndex].startTimeMs;
    });
    resetOnly();
    Navigator.pop(context);
  }

  void _toggleFullscreen() {
    setState(() {
      _visible = !_visible;
      if (_visible) {
        spacer = 8;
        _controller.reverse();
      } else {
        spacer = 0;
        _controller.forward();
      }
    });
  }

  void _showSheetUI() {
    showModalBottomSheet(
      context: context,
      builder:
          (cntx) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 72,
                  child: Center(
                    child: Text(
                      "Pick your mode",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView(
                    itemExtent: 96,
                    overAndUnderCenterOpacity: 0.8,
                    squeeze: 0.95,
                    physics: FixedExtentScrollPhysics(),
                    diameterRatio: 2,
                    children: List.generate(modes.length, (index) {
                      return ModeWidget(
                        mode: modes[index],
                        isSelected: index == modeIndex,
                        onTap: () => _setMode(index),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class Mode {
  final int startTimeMs;
  final String label;

  Mode({required this.label, required this.startTimeMs});
}

class ModeWidget extends StatelessWidget {
  final Mode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeWidget({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? Colors.blue : Colors.black38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode.label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "(${(mode.startTimeMs / 1000) ~/ 60} min ${(mode.startTimeMs / 1000) % 60} sec)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlidingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AnimationController controller;
  final PreferredSizeWidget child;

  const SlidingAppBar({required this.controller, required this.child});

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: ReverseAnimation(controller),
        curve: Curves.fastOutSlowIn,
      ),
      axisAlignment: 1.0,
      child: child,
    );
  }
}
