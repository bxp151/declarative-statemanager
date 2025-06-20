// FILE: log_manager.dart

import 'package:automath/models/step_log.dart';
import 'package:automath/managers/step_manager.dart';
import 'package:automath/daos/step_log_dao.dart';
import 'package:automath/constants/fluency_targets.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/models/problem_data.dart';


class LogManager {
  // Singleton instance
  static final LogManager _instance =
      LogManager._internal(); // Singleton instance
  factory LogManager() => _instance; // Always return the same instance
  LogManager._internal(); // Private constructor

  late StepManager stepManager; // Store reference to StepManager

  ProblemData get currentProblem => ProblemManager().currentProblem;


  // Setter for StepManager
  void setStepManager(StepManager manager) {
    stepManager = manager;
  }

  //  Getter for StepLog entries - delete
  List<StepLog> get stepLogs => List.unmodifiable(_stepLogs);

  // StepLog storage
  final List<StepLog> _stepLogs = [];

  // Method to add a StepLog entry
  void addStepLog(StepLog log) {
    _stepLogs.add(log);
  }

  //  Method to call create a new StepLog
  void logStep(String step) async {
    DateTime now = DateTime.now();
    bool isProblemStart =
        stepManager.stepStatus[step].toString() == "step_start";

    final int timeTaken = isProblemStart
        ? 0
        : now.difference(stepManager.lastTimeStamp).inSeconds;

    final logItem = StepLog(
      probLogID:
          "${currentProblem.probID}_${stepManager.firstStepTime.millisecondsSinceEpoch ~/ 1000}",
      probID: currentProblem.instanceID,
      queueName: currentProblem.queueName,
      priority: currentProblem.priority,
      interventionLevel: currentProblem.interventionLevel,
      overallLevel: currentProblem.overallLevel,
      gradeLevel: currentProblem.gradeLevel,
      subLevelScore: currentProblem.subLevelScore,
      paramLevelScore: currentProblem.paramLevelScore,
      probText: currentProblem.probText,
      paramType: currentProblem.paramType,
      numSteps: currentProblem.numSteps,
      stepNo: int.parse(step),
      stepCalc: currentProblem.stepHuman[step]["calculation_log"],
      attempt: isProblemStart
          ? 0
          : stepManager.attempt, // attempt=0 for first log entry
      evalStatus: stepManager.stepStatus[step].toString(),
      timeTaken: timeTaken,
      fluencyStepTimeGap: kMaxFluentStepSeconds - timeTaken,
    );

    addStepLog(logItem);
    stepManager.lastTimeStamp = now;

    if (logItem.evalStatus != "step_start") {
      await StepLogDao().insertStepLog(logItem);
    }
  }
}
