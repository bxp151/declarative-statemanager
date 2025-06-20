// File: step_manager.dart

// StepManager:
// - Manages the logic and state of problem-solving steps in a grid-based task.
// - Tracks step completion, correctness, and input status while controlling
//   locked cells for each step.
//
//   Key Responsibilities:
//   - Tracks completed steps and manages their completion state.
//   - Monitors user inputs to determine if all required parameters are filled.
//   - Validates step correctness and updates the step status accordingly.
//   - Locks and unlocks cells to control user modifications after step completion.
//   - Retrieves step-related information based on grid cell references.
//
//   Core Features:
//   - Step Completion: Tracks and marks steps as completed.
//   - Step Validation: Ensures user inputs are populated and correct.
//   - Locked Cells: Prevents modifications to completed steps.
//   - Caching: Stores step status to avoid redundant computations.
//   - Step Tracking: Determines which step a grid cell belongs to and checks
//     step correctness based on user inputs.
//
//   Methods:
//   - `completeStep(String step)`: Marks a step as completed.
//   - `isStepCompleted(String step)`: Checks if a step is completed.
//   - `resetSteps()`: Resets all completed steps.
//   - `lockCellsForStep(Set<String> cells)`: Locks specified cells for a step.
//   - `unlockCellsForStep(Set<String> cells)`: Unlocks specified cells for a step.
//   - `isCellLocked(String cell)`: Checks if a cell is locked.
//   - `getStepForCell(String rowKey, int index)`: Finds the step associated with a cell.
//   - `isStepPopulated(String step, List<dynamic> params, Map<String, String> userInputs)`:
//       Checks if a step has all required inputs.
//   - `isStepCorrect(String step, List<dynamic> params, Map<String, bool?> answerState)`:
//       Validates a step's correctness.
//   - `evaluateStepStatus(String? step, Map<String, String> userInputs, Map<String, bool?> answerState)`:
//       Evaluates a step’s status and caches the result.
//
// Notes:
//   - Uses step status flags, completion tracking, and cell-locking mechanisms
//     to guide users through a structured step-by-step approach.
//   - Designed to work alongside other grid-based components, ensuring accurate
//     validation and progress tracking.

import 'package:flutter/material.dart';
import 'log_manager.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/models/problem_data.dart';
import 'package:automath/managers/grid_manager.dart';
import 'package:automath/managers/sound_manager.dart';
import 'package:automath/managers/state_manager.dart';

class StepManager extends ChangeNotifier {
  static final StepManager _instance = StepManager._internal();
  factory StepManager() => _instance;
  StepManager._internal() {
    LogManager().setStepManager(this);
  }

  late DateTime problemStartTime;

  // Tracks last timestamp for leg entry "time taken"
  DateTime lastTimeStamp = DateTime.now();

  // Tracks the first step time for primary key
  DateTime firstStepTime = DateTime.now();

  // Tracks the current feedback for the latest error.
  String _stepFeedback = "";

  // Tracks the completed steps
  final Set<String> _completedStepsNew = {};

  // Tracks number of attempts per step
  int attempt = 1;

  // Tracks step status
  final Map<String, String> _stepStatus = {};

  // Tracks number of incorrect steps
  int _numberIncorrectSteps = 0;

  // Tracks stepEvalStatus return
  String _evalStatus = "";

  int quickSolveSecondsLeft = 100;
  // setter for _quickSolveSecondsLeft

  // Getters and setters
  String get evalStatus => _evalStatus;
  Map<String, String> get stepStatus => _stepStatus;
  ProblemData get currentProblem => ProblemManager().currentProblem;
  String get stepFeedback => _stepFeedback;
  bool get isProblemComplete => _isProblemComplete();
  Set<String> get completedSteps => _completedStepsNew;
  GridManager get gridManager => GridManager();
  bool get isProblemCorrectFirstTry => _isProblemCorrectFirstTry();
  // bool get isProblemCompleteFlag => _isProblemCompleteFlag;

  // resets StateManager state variables
  void resetStepManagerState() {
    _completedStepsNew.clear();
    _stepStatus.clear();
    _lockedCells.clear();
    _incorrectCells.clear();
    _numberIncorrectSteps = 0;
    _evalStatus = "start";
    // _isProblemCompleteFlag = false;
  }

  // Adds correct steps to a set
  void completeStepNew(String step) {
    if (!_completedStepsNew.contains(step)) {
      _completedStepsNew.add(step);
    }
  }

  // Checks if a step is completed
  bool isStepCompletedNew(String step) {
    return _completedStepsNew.contains(step);
  }

  // Resets the completed steps (if needed in the future)
  void resetStepsNew() {
    _completedStepsNew.clear();
    notifyListeners();
  }

  // Returns true if only if all steps are "step_complete"
  bool _isProblemComplete() {
    for (int i = 1; i <= stepStatus.length; i++) {
      // print("stepStatus: $i | ${stepManager.stepStatus[i.toString()]}");
      if (stepStatus[i.toString()] != "step_correct") {
        return false;
      }
    }
    return true;
  }

  // Tracks locked cells
  final Set<String> _lockedCells = {};
  Set<String> get lockedCells => _lockedCells;

  // Tracks incorrect cells
  final Set<String> _incorrectCells = {};
  Set<String> get incorrectCells => _incorrectCells;

  // Locks the cells for a given step
  void lockCellsForStep(Set<String> cells) {
    _lockedCells.addAll(cells);
  }

  // Unlocks the cells for a given step
  void unLockCellsForStep(Set<String> cells) {
    // print("Before unlocking cells: $_lockedCells");
    _lockedCells.removeAll(cells);
    // print("After unlocking cells: $_lockedCells");
  }

  // Stores incorrect cells
  void storeIncorrectCells(Set<String> cells) {
    _incorrectCells.addAll(cells);
  }

  // Purges incorrect cells
  void purgeIncorrectCell(String cell) {
    _incorrectCells.remove(cell);
  }

  // Check if a cell is part of an incorrect step
  bool isCellinIncorrectStep(String cell) {
    return _incorrectCells.contains(cell);
  }

  // Checks if a specific cell is locked
  bool isCellLocked(String cell) {
    // print("isCellLocked called for cell: $cell - Locked: ${_lockedCells.contains(cell)}");
    return _lockedCells.contains(cell);
  }

  // Returns all parameters within a step given a cell address
  Set<String> getParamsFromCell(rowKey, index) {
    final step = getStepForCell(rowKey, index);
    final params = currentProblem.stepsToParams[step];
    final paramSet = mapParamsToStringSet(params);
    return paramSet;
  }

  // Unlocks all cells associated with a step given a cell address
  void unlockCellsInStep(rowKey, index) {
    final params = getParamsFromCell(rowKey, index);
    print("The params are: $params");
    unLockCellsForStep(params);
    // final paramsList = params.toList();
  }

  // Returns the step where a given cell lives
  String? getStepForCell(String rowKey, int index) {
    final step = currentProblem.stepMap[rowKey]?[index];
    return step?.toString(); // Return the step value
  }

  // Converts mapped parameters -> string set
  Set<String> mapParamsToStringSet(params) {
    return params.map((param) => param.toString()).toSet().cast<String>();
  }

  /// Returs true is problem is correct on the first try
  bool _isProblemCorrectFirstTry() {
    return (_isProblemComplete() && _numberIncorrectSteps == 0);
  }

  // Get cached version of step status
  String getCachedStepStatus(String step) {
    return _stepStatus[step] ?? "step_start";
  }

  // Determines if the step is correct Returns
  // null: incomplete, true, or false
  dynamic isStepCorrect(dynamic params, Map<String, bool?> answerState) {
    return params.map((param) => answerState[param]).reduce(
        (acc, state) => acc == null || state == null ? null : acc && state);
  }

  // Evaluates a setp (correct, incorrect, incomplete)
  Future<String> stepEvalStatus(
      String step, Map<String, bool?> answerState) async {
    // Return cached status if it exists
    if (_stepStatus.containsKey(step)) {
      return _stepStatus[step]!;
    }

    // Gets parameters from the mapping
    final params = currentProblem.stepsToParams[step];

    if (params == null || params.isEmpty) {
      _evalStatus = "null_error";
      return _evalStatus;
    }

    // null means one or more steps is missing
    if (isStepCorrect(params, answerState) == null) {
      // _evalStatus = "step_incomplete";
      return "step_incomplete";
    }

    if (isStepCorrect(params, answerState) == false) {
      _evalStatus = "step_incorrect";
      storeIncorrectCells(mapParamsToStringSet(params));
      attempt++;
      _numberIncorrectSteps++;
    }

    if (isStepCorrect(params, answerState) == true) {
      _evalStatus = "step_correct";
      completeStepNew(step); // Mark step complete if it is correct
      attempt = 1;

      // Unlock the next step if this isn't the last step
      if (int.parse(step) != currentProblem.stepsToParams.length) {
        final nextStep = (int.parse(step) + 1).toString();
        final paramsNext = currentProblem.stepsToParams[nextStep];
        unLockCellsForStep(mapParamsToStringSet(paramsNext));
        _stepStatus[nextStep] = "step_incomplete";
      }
    }
    // For completed step, lock the step
    lockCellsForStep(mapParamsToStringSet(params));
    // print("Locked Cells: $_lockedCells");
    _stepStatus[step] = _evalStatus;
    await SoundManager().playSoundBasedOnName(soundName: _evalStatus);
    LogManager().logStep(step);
    StateManager()
        .insertStateLogEntry(stateName: 'evalStatus', stateValue: _evalStatus);
    notifyListeners();
    return _evalStatus;
  }

  // Gets human readable step_incorrect for incorrect steps
  void setFeedbackForStep(String step, String stepEvalStatus) {
    if (stepEvalStatus == "step_incorrect") {
      _stepFeedback = currentProblem.stepHuman[step]?['feedback'] ??
          "Unknown error at step $step.";
    } else {
      _stepFeedback = "";
    }
  }

  /// Determines the background color of a cell based on its step's status.
  Color getCellBackgroundColor(String rowKey, int colKey) {
    final step = getStepForCell(rowKey, colKey);
    if (step == null) {
      return const Color(0xFFD9D9D9); // Grey for unlinked steps
    }

    final stepStatus = getCachedStepStatus(step);

    // print("Cell: $rowKey$colKey | Status: $stepStatus");

    if ((stepStatus == "step_incomplete") || (stepStatus == "step_start")) {
      return const Color(0xFFF2F2F2); // Grey for unpopulated steps
    } else if (stepStatus == "step_correct") {
      return const Color(0xFFA6CAEC); // Light blue for correct steps
    } else if (stepStatus == "step_incorrect") {
      return const Color(0xFFF6C6AD); // Orange for incorrect steps
    } else if (stepStatus == "step_hidden") {
      return const Color(0xFFB0B0B0); // A slightly darker gray for locked cells
    }
    return const Color(0xFFD9D9D9);
  }

  bool shouldShowCheckIcon(String rowKey, int colKey) {
    final step = getStepForCell(rowKey, colKey);
    if (step == null) return false;

    final stepStatus = getCachedStepStatus(step);
    return stepStatus == "step_correct";
  }

  /// Determines if an X icon should be shown for a cell.
  bool shouldShowXIconNew(String rowKey, int colKey) {
    final step = getStepForCell(rowKey, colKey);
    if (step == null) return false;

    final stepStatus = getCachedStepStatus(step);
    return stepStatus == "step_incorrect";
  }

  String getFeedbackType(String step) {
    final stepStatus = getCachedStepStatus(step);
    if (stepStatus == "step_correct") {
      return "positive";
    } else if (stepStatus == "step_incorrect") {
      return "step_incorrect";
    } else {
      return "none";
    }
  }
}
