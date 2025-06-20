// FILE: problem_start_scaffold.dart
import 'package:automath/managers/grid_manager.dart';
import 'package:flutter/material.dart';
import 'package:automath/managers/problem_manager.dart';

class ProblemLoadScaffold extends StatefulWidget {
  final bool isFirstProblemInSession;
  const ProblemLoadScaffold({super.key, this.isFirstProblemInSession = true});
  @override
  State<ProblemLoadScaffold> createState() => _ProblemLoadScaffoldState();
}

class ProblemLoadingResult {
  final String nextRoute;
  final String loadingMessage;
  ProblemLoadingResult(this.nextRoute, this.loadingMessage);
}

class _ProblemLoadScaffoldState extends State<ProblemLoadScaffold> {
  late final Future<ProblemLoadingResult> _initFuture;
  bool _navigated = false;
  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  GridManager get gridManager => GridManager();
  final Map<String, String> firstProblem = {
    'queue_10_full_view': "Let's start with a regular problem 🧮",
    'queue_11_answer_view': "Let's start with a regular problem 🧮",
    'queue_12_carry_view': "Let's start with a regular problem 🧮",
    'queue_13_operand_view': "Let's start with a regular problem 🧮",
    'queue_30_step_review_view': "Let's start with a step review 🧩",
    'queue_01_intervention_view': "Let's start with a step review 🧩",
    'queue_40_problem_review_view': "Let's start with a problem review 🔁",
  };
  final Map<String, String> nextProblem = {
    'queue_10_full_view': "",
    'queue_11_answer_view': "",
    'queue_12_carry_view': "",
    'queue_13_operand_view': "",
    'queue_01_intervention_view': "Let's review those incorrect step(s) 🧩",
    'queue_30_step_review_view': "Let's review a previous incorrect step 🧩",
    'queue_40_problem_review_view':
        "Let's review a previous incorrect problem 🔁",
  };
  Future<ProblemLoadingResult> _initializeApp() async {
    await ProblemManager().loadNextProblemFromQueueAll();
    gridManager.resetStateAndInitializeStepLog();
    // Get queName from next problem
    final queueName = ProblemManager().currentProblem.queueName;
    final quickSolveFlag = ProblemManager().currentProblem.quickSolveFlag;
    late String message;
    if (quickSolveFlag == 1) {
      message = widget.isFirstProblemInSession
          ? "Let's start with a timed problem 🕒"
          : "Let's continue with a timed problem 🕒";
    } else {
      message = widget.isFirstProblemInSession
          ? firstProblem[queueName] ?? "Let's get started"
          : nextProblem[queueName] ?? "Let's continue";
    }
    return ProblemLoadingResult('/problemscreen', message);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProblemLoadingResult>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final delay = (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.loadingMessage == "")
                ? 100
                : 2000;
            await Future.delayed(Duration(milliseconds: delay));
            if (mounted) {
              Navigator.pushReplacementNamed(context, snapshot.data!.nextRoute);
            }
          });
        }
        final showMessage = (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData)
            ? snapshot.data!.loadingMessage
            : '';
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              showMessage,
              style: const TextStyle(color: Colors.white, fontSize: 48),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
