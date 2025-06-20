// file: keyboard_manager.dart

import 'package:flutter/material.dart';


class KeyboardManager with ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void showKeyboard() {
    _isVisible = true;
    notifyListeners();
  }

  void hideKeyboard() {
    _isVisible = false;
    notifyListeners();
  }

  void updateKeyboardVisibility(String stepState) {
    if (stepState == "step_incomplete" || stepState == "step_incorrect") {
      showKeyboard();
    } else if (stepState == "step_correct") {
      hideKeyboard();
    }
  }
}
