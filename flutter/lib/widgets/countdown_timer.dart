// file: countdown_timer.dart
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/constants/fluency_targets.dart';
import 'package:automath/managers/step_manager.dart';

class CountdownTimer extends StatefulWidget {
  // final int duration;
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  @override
  void initState() {
    super.initState();
  }

  StepManager get stepManager => StepManager();
  final CountDownController _controller = CountDownController();

  int _lastTime =
      ProblemManager().currentProblem.numSteps * kMaxTimeLimitPerStep +
          kProblemLoadBufferTime;

  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 5,
      height: MediaQuery.sizeOf(context).height / 5,
      color: Colors.white,
      child: CircularCountDownTimer(
        // Countdown duration in Seconds.
        controller: _controller,
        duration:
            ProblemManager().currentProblem.numSteps * kMaxTimeLimitPerStep +
                kProblemLoadBufferTime,
        // Countdown initial elapsed Duration in Seconds.
        initialDuration: 0,
        // Width of the Countdown Widget.
        width: MediaQuery.sizeOf(context).width / 5,
        // Height of the Countdown Widget.
        height: MediaQuery.sizeOf(context).height / 5,
        // Ring Color for Countdown Widget.
        ringColor: Colors.grey[300]!,
        // Ring Gradient for Countdown Widget.
        ringGradient: null,
        // Filling Color for Countdown Widget.
        fillColor: Colors.grey,
        // Filling Gradient for Countdown Widget.
        fillGradient: null,
        // Background Color for Countdown Widget.
        backgroundColor: Colors.blueAccent,
        // Background Gradient for Countdown Widget.
        backgroundGradient: null,
        // Border Thickness of the Countdown Ring.
        strokeWidth: 20.0,
        // Begin and end contours with a flat edge and no extension.
        strokeCap: StrokeCap.round,
        // Text Style for Countdown Text.
        textStyle: const TextStyle(
          fontSize: 33.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        // Format for the Countdown Text.
        textFormat: CountdownTextFormat.S,
        // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
        isReverse: true,
        // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
        isReverseAnimation: true,
        // Handles visibility of the Countdown Text.
        isTimerTextShown: true,
        // Handles the timer start.
        autoStart: true,
        // This Callback will execute when the Countdown Starts.
        onStart: () {
          // Here, do whatever you want
          debugPrint('Countdown Started');
        },
        // This Callback will execute when the Countdown Ends.
        onComplete: () {
          // Here, do whatever you want
          debugPrint('Countdown Ended');
        },
        // This Callback will execute when the Countdown Changes.
        onChange: (String timeStamp) {
          int intTimeStamp = int.parse(timeStamp);
          if (intTimeStamp != _lastTime && !_isPaused) {
            _lastTime = intTimeStamp;
            stepManager.quickSolveSecondsLeft = intTimeStamp;
            debugPrint("quickSolveSecondsLeft: $timeStamp");
            if (stepManager.isProblemComplete) {
              _controller.pause();
              _isPaused = true;
              print("ispaused: $_isPaused");
            }
          }
        },
      ),
    );
  }
}
