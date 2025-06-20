// File: grid_manager.dart
import 'package:flutter/material.dart';
import 'dart:collection';
import 'step_manager.dart';
import 'log_manager.dart';
import 'package:automath/daos/process_log_dao.dart';
import 'package:automath/models/problem_data.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/managers/progression_manager.dart';
import 'package:automath/daos/problem_log_dao.dart';
import 'package:automath/managers/sound_manager.dart';

/// GridManager:
/// - A state management class for handling grid logic, user inputs, and validation.
///
/// Parameters:
/// - [paramGrid]: The initial grid structure, including placeholders and labels.
/// - [solvedGrid]: The grid containing the correct answers for validation.
/// - [stepMap]: A mapping that links grid cells to specific steps for guided problem-solving.
/// - [stepHuman]: A human-readable map providing detailed step-by-step instructions and feedback.
///
/// Features:
/// - Tracks user inputs and compares them against the solved grid for validation.
/// - Provides feedback for incorrect inputs, including step-specific error messages.
/// - Dynamically notifies listeners (e.g., UI components) of changes in grid state.
/// - Supports retrieval of validation states and user inputs for debugging or external use.
///
/// Notes:
/// - Each grid cell is uniquely identified using a combination of its row and column indices.
/// - Feedback is updated dynamically to guide the user through solving the grid.
///
///
class GridManager extends ChangeNotifier {
  static final GridManager _instance = GridManager._internal();
  factory GridManager() => _instance;
  GridManager._internal() {
    resetStateAndInitializeStepLog();
  }

  bool isComplete = false;

  // Multiple sets
  final int _setNo = 1; // Index of the current set
  int get setNo => _setNo;

  Set<String> _initialLockParams = {};

  // Tracks user inputs and validation results.
  final Map<String, String> _userInputs = {}; // Stores user input values.
  final Map<String, bool?> _answerState = {}; // Tracks validation status.

  // Exposes _generateKey for external use.
  String generateKey(String rowKey, int colKey) => _generateKey(rowKey, colKey);
  String feedbackType = "start";

  // Tracks first grid rendering
  bool _isFirstRender = true;

  // For the feedback track
  bool _isTrayVisible = false;

  // Tracks if problem is correct on first try
  bool _isProblemCorrectFirstTry = false;

  // Getters and setters
  StepManager get stepManager => StepManager();
  bool get isProblemCorrectFirstTry => _isProblemCorrectFirstTry;
  int get numStepsCompleteNew =>
      stepManager.completedSteps.length; // Number of steps complete
  bool get isTrayVisible => _isTrayVisible;
  bool get isFirstRender => _isFirstRender;
  ProblemData get currentProblem => ProblemManager().currentProblem;

  // resets GridManager state variables
  void resetGridManagerState() {
    _initialLockParams.clear();
    _userInputs.clear();
    _answerState.clear();
    isComplete = false;
    feedbackType = "start";
  }

  //  Increments to next problem, resets state, and initializes next problem
  Future<void> resetStateAndInitializeStepLog() async {
    // Reset manager states
    resetGridManagerState();
    stepManager.resetStepManagerState();
    _initialLockParams = extractInitialLockParams(currentProblem.stepsToParams);
    stepManager.lockCellsForStep(_initialLockParams);
    initializeStepLog();
    notifyListeners();
  }

  void initializeStepLog() {
    // Initialize stepStatus
    for (int i = 1; i <= currentProblem.stepsToParams.length; i++) {
      if (i == 1) {
        stepManager.stepStatus[i.toString()] = "step_start";
      } else {
        stepManager.stepStatus[i.toString()] = "step_hidden";
      }
      // print("The value of stepStatus is: ${stepManager.stepStatus}");
    }

    // Intialize stepLog with first entry
    stepManager.problemStartTime = DateTime.now();
    LogManager().logStep("1");
  }

  ///////////////////////////////////////////////////////////////////////
  ///===================================================================
  ///   START | INPUT PROCESSING AND PROBLEM CONTROL
  /// ==================================================================

  Future<void> processInputAndAdvance(
      String rowKey, int colKey, String value) async {
    // Get step number from keys
    final step = stepManager.getStepForCell(rowKey, colKey);
    if (step == null) {
      return;
    }

    // Initialize input fields | set user input | set answer state
    _initializeInputFields(step);
    _setUserInputAndAnswerState(rowKey, colKey, value);

    // returns step_correct, step_incorrect, step_incomplete, null_error
    final stepStatus = await stepManager.stepEvalStatus(step, answerState);

    // Gets human readable feedback for incorrect step
    stepManager.setFeedbackForStep(step, stepStatus);

    // Set the feedback type for the feedback tray
    feedbackType = stepManager.getFeedbackType(step);

    // Trigger the FeedbackTray
    _isTrayVisible = true; // Always make the tray visible
    notifyListeners(); // Notify UI of the change

    // Summarize steps if problem is complete
    if (stepManager.isProblemComplete) {
      _isProblemCorrectFirstTry = stepManager.isProblemCorrectFirstTry;
      notifyListeners();

      if (_isProblemCorrectFirstTry) {
        await SoundManager().playSoundBasedOnName(soundName: "problem_correct");
      } else {
        await SoundManager()
            .playSoundBasedOnName(soundName: "problem_incorrect");
      }

      await ProcessLogDao().processLogsSequentially();
      await ProblemLogDao()
          .updateProblemAttemptLog(instanceID: currentProblem.instanceID);
      await ProgressionManager().getAndSetLevels();

      // Grid Manager processing is complete
      isComplete = true;
    }
  }

  void _setAnswerState(String rowKey, int colKey, String value) {
    final gridKey = _generateKey(rowKey, colKey);
    final expectedValue =
        currentProblem.solvedGrid[rowKey]?[colKey]?.toString();

    bool isValid = value == expectedValue;
    _answerState[gridKey] = isValid;
  }

  void _initializeInputFields(String step) {
    _isFirstRender = false;
    feedbackType = "";
    stepManager.stepStatus.remove(step);
  }

  void _setUserInputAndAnswerState(rowKey, colKey, value) {
    final gridKey = _generateKey(rowKey, colKey);
    _userInputs[gridKey] = value;
    _setAnswerState(rowKey, colKey, value);
  }

  ///===================================================================
  ///   END | INPUT PROCESSING AND PROBLEM CONTROL
  /// ==================================================================
  /// //////////////////////////////////////////////////////////////////

  /// Retrieves the validation state for a specific cell.
  bool? getAnswerState(String rowKey, int colKey) {
    final gridKey = _generateKey(rowKey, colKey);
    return _answerState[gridKey];
  }

  void resetValidationState(String rowKey, int colKey) {
    final gridKey = _generateKey(rowKey, colKey);
    // print("gridKey is: $gridKey");
    _answerState[gridKey] = null; // Reset validation state to null or default
    _userInputs[gridKey] = ''; // Clear the user input
    stepManager
        .purgeIncorrectCell(gridKey); // removes gridKey from incorrect cell set
    final step = stepManager.getStepForCell(rowKey, colKey);
    if (step != null) {
      stepManager.stepStatus.remove(step);
      feedbackType = "none";
      stepManager.setFeedbackForStep(step, feedbackType);
    }
    _isProblemCorrectFirstTry = false;
    notifyListeners(); // Notify the UI to update
  }

  // Helper: Generates a unique gridKey for a grid cell.
  String _generateKey(String rowKey, int colKey) {
    // Remove any existing pipe from the rowKey
    if (rowKey.contains('|')) {
      rowKey = rowKey.replaceAll('|', '');
    }
    return '$rowKey|$colKey';
  }

  // Unlocks all step cells given a cell address
  void unlockCellsInStep(rowKey, colKey) {
    // print("unlockCellInStep passes rowkey: $rowKey colKey: $colKey");
    stepManager.unlockCellsInStep(rowKey, colKey);
    // notifyListeners(); // Ensure UI rebuilds
  }

  // Deletes the values from cell address
  void deleteCell(cell) {
    final splitCell = cell.split("|");
    final rowKey = splitCell[0] + "|";
    final colKey = int.parse(splitCell[1]);
    resetValidationState(rowKey, colKey);
  }

  // Delete step values given a cell address
  void deleteCellsInStep(rowKey, colKey) {
    final params = stepManager.getParamsFromCell(rowKey, colKey);
    params.forEach(deleteCell);
    notifyListeners();
  }

  // Extracts the initial problem lock parameters excluding the first gridKey
  // Purpose: only one step in the problems should be solvable at a time
  // Return empty set if there is only one gridKey
  Set<String> extractInitialLockParams(Map<String, dynamic> map) {
    int keyCount = map.length; // Get the total number of keys
    if (keyCount > 1) {
      return map.entries
          .where((entry) => entry.key != "1")
          .expand((entry) => entry.value is Iterable
              ? entry.value
              : []) // Safely handle non-iterables
          .map((param) => param.toString()) // Convert to String
          .toSet(); // Ensure uniqueness
    }
    return <String>{};
  }

  // Getters for debugging or exporting state.
  UnmodifiableMapView<String, String> get userInputs =>
      UnmodifiableMapView(_userInputs);

  UnmodifiableMapView<String, bool?> get answerState =>
      UnmodifiableMapView(_answerState);
}
