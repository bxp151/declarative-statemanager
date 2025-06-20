// FILE: feedback_manager.dart

import 'package:automath/managers/step_manager.dart';
import 'package:automath/constants/feedback_messages.dart';

class FeedbackManager {
  StepManager get stepManager => StepManager();

  String getFeedbackMessage(
      {required String evalStatus, required stepFeedback}) {
    String emojiType = "";
    String feedbackType = "";

    // Problem complete
    if (stepManager.isProblemComplete) {
      if (stepManager.isProblemCorrectFirstTry) {
        emojiType = "problem_correct";
        feedbackType = "positive";
      } else {
        emojiType = "problem_incorrect";
        feedbackType = "problem_incorrect";
      }
    }

    // Problem incomplete
    if (!stepManager.isProblemComplete) {
      switch (evalStatus) {
        case "start":
          feedbackType = "start";
          break;
        case "step_correct":
          feedbackType = "positive";
          break;
        case "step_incorrect":
          feedbackType = "step_incorrect";
          break;
        default:
          feedbackType = "none";
      }
    }

    // Use emojiType and feedbackType to randomly pick and return feedback
    final String message =
        FeedbackMessages.getRandomFeedbackMessage(feedbackType: feedbackType);
    if (emojiType != "") {
      final String emoji =
          FeedbackMessages.getRandomFeedbackEmoji(emojiType: emojiType);
      return "$emoji  $message";
    }
    if (stepFeedback != "") {
      return "$message \n $stepFeedback";
    }
    return message;
  }
}
