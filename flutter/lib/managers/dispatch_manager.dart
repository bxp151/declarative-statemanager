// file: dipatch_manager.dart

import 'package:automath/widgets/feedback_tray_widget.dart';
import 'package:flutter/widgets.dart';

class DispatchManager {
  // Singleton instance
  static final DispatchManager _instance = DispatchManager._internal();
  factory DispatchManager() => _instance;
  DispatchManager._internal();

  // Registers the GlobalKey
  GlobalKey<FeedbackTrayWidgetState>? feedbackTrayKey;
  void registerFeedbackTrayKey(GlobalKey<FeedbackTrayWidgetState> key) {
    feedbackTrayKey = key;
  }

  // Call widget rebuild using the GlobalKey
  Map<String, void Function(String)> get stateUpdate => {
        'evalStatus': (value) =>
            feedbackTrayKey?.currentState?.updateEvalStatus(value),
      };
}
