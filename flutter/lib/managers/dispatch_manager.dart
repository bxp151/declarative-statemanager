// file: dipatch_manager.dart

// import 'package:automath/widgets/feedback_tray_widget.dart';
import 'package:demo/main_declarative.dart';
import 'package:flutter/material.dart';

class DispatchManager {
  // Singleton instance
  static final DispatchManager _instance = DispatchManager._internal();
  factory DispatchManager() => _instance;
  DispatchManager._internal();

  // Registers the GlobalKeys
  GlobalKey<BoxWidgetState>? boxAKey;
  GlobalKey<BoxWidgetState>? boxBKey;

  void registerBoxAkey(GlobalKey<BoxWidgetState> key) {
    boxAKey = key;
  }

  void registerBoxBkey(GlobalKey<BoxWidgetState> key) {
    boxBKey = key;
  }

  // Call widget rebuild using the GlobalKey
  Map<String, void Function(String)> get stateUpdate => {
        'switchAvalue': (value) {
          final color = value == 'true' ? Colors.blue : Colors.grey;
          boxAKey?.currentState?.updateColor(color);
        },
        'switchBvalue': (value) {
          final color = value == 'true' ? Colors.deepOrangeAccent : Colors.grey;
          boxBKey?.currentState?.updateColor(color);
        }
      };
}
