// file: dispatch_manager.dart

// import 'package:automath/widgets/feedback_tray_widget.dart';
import 'package:demo/main_declarative.dart';
import 'package:flutter/material.dart';
import 'package:demo/daos/state_manager_dao.dart';

class DispatchManager {
  // Singleton instance
  static final DispatchManager _instance = DispatchManager._internal();
  factory DispatchManager() => _instance;
  DispatchManager._internal();

  // Create fields and methods to register the keys. This enables the
  // central manager to control widget state externally.
  GlobalKey<BoxWidgetState>? boxAKey;
  GlobalKey<BoxWidgetState>? boxBKey;
  void registerBoxAkey(GlobalKey<BoxWidgetState> key) {
    boxAKey = key;
  }

  void registerBoxBkey(GlobalKey<BoxWidgetState> key) {
    boxBKey = key;
  }

  // Create mapping from stateName (user selected) and state value to the
  // desired widget rebuild result. Here I'm mapping the switch value to a
  // desired color based on a Boolean.
  Map<String, void Function(String)> updateCurrentState() {
    return {
      'switchAvalue': (value) {
        final color = value == 'true' ? Colors.blue : Colors.grey;
        boxAKey?.currentState?.updateColor(color);
      },
      'switchBvalue': (value) {
        final color = value == 'true' ? Colors.deepOrangeAccent : Colors.grey;
        boxBKey?.currentState?.updateColor(color);
      },
    };
  }

  // Call widget rebuild using the GlobalKey
  Future<void> updateState(
      {required int stateLogID,
      required String stateName,
      required dynamic stateValue}) async {
    final stateUpdateMap = updateCurrentState();

    // Dispatch widget to build
    stateUpdateMap[stateName]?.call(stateValue.toString());

    // Update the dispatch timestamp
    await StateManagerDao().updateDispatchTimestamp(stateLogID: stateLogID);
  }
}
