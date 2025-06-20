// file: state_manager.dart
import 'package:demo/daos/state_manager_dao.dart';
import 'dart:async';
import 'package:demo/managers/dispatch_manager.dart';

class StateManager {
  // Singleton instance
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  late Timer evaluatorTimer;
  bool _isEvaluatorRunning = false;

  // Insert a state log entry
  Future<int> insertStateLogEntry({
    required String originWidget,
    required String originMethod,
    required String stateName,
    required String stateValue,
  }) async {
    final stepLogID = await StateManagerDao().insertStateLogEntry(
        originWidget: originWidget,
        originMethod: originMethod,
        stateName: stateName,
        stateValue: stateValue);

    return stepLogID;
  }

  // Checks every 100ms if there are any dirty states
  Future<void> startEvaluatorLoop() async {
    evaluatorTimer = Timer.periodic(Duration(milliseconds: 100), (_) async {
      if (_isEvaluatorRunning) return;

      _isEvaluatorRunning = true;
      try {
        await updateWidgetsIfNeeded();
      } finally {
        _isEvaluatorRunning = false;
      }
    });
  }

  void stopEvaluatorLoop() {
    evaluatorTimer.cancel();
  }

  Future<void> updateWidgetsIfNeeded() async {
    final qryState = await StateManagerDao().getStates();
    if (qryState.isEmpty) {
      return;
    }
    for (final row in qryState) {
      final stateLogID = row['stateLogID'] as int;
      final stateName = row['stateName'] as String;
      final stateValue = row['stateValue'] as String;

      // add a wrapper and pass the stateLogiD here
      // update the dispatchTimestamp in that method
      DispatchManager().stateUpdate[stateName]?.call(stateValue);
    }
  }
}
