// file: state_manager.dart
import 'package:automath/daos/state_manager_dao.dart';
import 'dart:async';

import 'package:automath/managers/dispatch_manager.dart';

class StateManager {
  // Singleton instance
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  late Timer evaluatorTimer;
  bool _isEvaluatorRunning = false;

  // Insert a state log entry
  Future<void> insertStateLogEntry(
      {required String stateName, required stateValue}) async {
    await StateManagerDao().insertStateLogEntry(stateName, stateValue);
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
      final stateName = row['stateName'] as String;
      final stateValue = row['stateValue'] as String;
      await StateManagerDao()
          .upsertWidgetBuildStatusAndTimestamp(stateName: stateName);
      DispatchManager().stateUpdate[stateName]?.call(stateValue);
    }
  }
}
