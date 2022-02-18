import 'dart:math';

import 'package:LESSs/style.dart';
import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  late AnimationController timerController;

  String get timerString {
    Duration duration = timerController.duration! * timerController.value;
    return '${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );

    timerController.reverse(
        from: timerController.value == 0.0 ? 1.0 : timerController.value);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Center(
        child: AnimatedBuilder(
            animation: timerController,
            builder: (context, child) {
              return Text(
                timerString,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18.0,
                    color: highlightColor,
                    fontWeight: FontWeight.bold),
              );
            }),
      ),
    );
  }
}
