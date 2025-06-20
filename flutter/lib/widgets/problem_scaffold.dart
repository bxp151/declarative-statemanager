// FILE: problem_scaffold.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automath/widgets/math_problem_grid.dart';
import 'package:automath/managers/grid_manager.dart';
import 'package:automath/widgets/feedback_tray_widget.dart';
import 'package:automath/widgets/countdown_timer.dart';
import 'package:automath/managers/dispatch_manager.dart';

/// ProblemScaffold:
/// - The main scaffold of the MathStairs UI.
/// - Displays the math problem grid and feedback tray.
class ProblemScaffold extends StatefulWidget {
  const ProblemScaffold({super.key});
  @override
  State<ProblemScaffold> createState() => _ProblemScaffoldState();
}

class _ProblemScaffoldState extends State<ProblemScaffold> {
  final GlobalKey<FeedbackTrayWidgetState> feedbackTrayKey =
      GlobalKey<FeedbackTrayWidgetState>();
  @override
  void initState() {
    super.initState();
    DispatchManager().registerFeedbackTrayKey(feedbackTrayKey);
  }

  void _handleLeftSwipe() async {
    final gridManager = Provider.of<GridManager>(context, listen: false);
    if (gridManager.isComplete) {
      Navigator.pushNamed(
        context,
        '/problemloadingscaffold',
        arguments: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MathStairs'),
          backgroundColor: Colors.blue,
        ),
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (details.delta.dx < -10) {
              // Adjust threshold as needed
              print("Swiped left!");
              _handleLeftSwipe();
            }
          },
          child: Stack(
            children: [
              // Main content (grid and feedback widget)
              Column(
                children: [
                  const SizedBox(height: 150.0), // Spacer at the top
                  // if (ProblemManager().isProblemQuickSolve()) // Add this later
                  CountdownTimer(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: MathProblemGrid(
                        gridManager:
                            Provider.of<GridManager>(context, listen: false),
                      ),
                    ),
                  ),
                ],
              ),
              // FeedbackTray explicitly positioned at the bottom
              Positioned(
                bottom: 0, // Ensures the FeedbackTray is pinned to the bottom
                left: 0,
                right: 0,
                child: FeedbackTrayWidget(key: feedbackTrayKey),
              ),
            ],
          ),
        ));
  }
}
