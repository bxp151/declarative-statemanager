// file: state_manager.dart
import 'package:demo/daos/state_manager_dao.dart';
import 'dart:async';
import 'package:demo/managers/dispatch_manager.dart';

class StateManager {
  // Singleton instance
  static final StateManager _instance = StateManager._internal();
  factory StateManager() => _instance;
  StateManager._internal();

  Future<int> dispatchWidgetBuild({
    required String originWidget,
    required String originMethod,
    required String stateName,
    required String stateValue,
  }) async {
    final stateLogID = await StateManagerDao().insertStateLogEntry(
        originWidget: originWidget,
        originMethod: originMethod,
        stateName: stateName,
        stateValue: stateValue);

    // Dispatches the state change and updates dispatchTimestamp
    await DispatchManager().updateState(
        stateLogID: stateLogID, stateName: stateName, stateValue: stateValue);

    return stateLogID;
  }

  Future<void> updateWidgetPostFrame(
      {required int stateLogID, required String widgetRebuildResult}) async {
    await StateManagerDao().updateWidgetPostFrame(
        stateLogID: stateLogID, widgetRebuildResult: widgetRebuildResult);
  }
}
