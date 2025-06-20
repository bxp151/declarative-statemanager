// file: feedback_messages.dart

import 'dart:math';

class FeedbackMessages {
  static const Map<String, List<String>> messages = {
    "start": [
      "Let's go!",
      "Ready?",
      "Your turn!",
      "Try it!",
      "Get started!",
      "Begin!",
      "Start now!",
      "Go for it!",
      "Solve it!",
      "Make a move!",
      "All set?",
      "Let’s do this!",
      "Jump in!",
      "You’ve got this!",
      "Take the first step!",
      "Go ahead!",
      "Your move!",
      "Let’s try!",
      "Dive in!",
      "Kick it off!",
      "Start solving!",
      "Over to you!",
      "Take a shot!",
      "Let’s begin!",
      "Have a go!"
    ],
    "positive": [
      "Great job",
      "Nice work!",
      "Well done!",
      "That’s right!",
      "Keep it up!",
      "Awesome!",
      "Excellent!",
      "Perfect!",
      "Way to go!",
      "You nailed it!",
      "Spot on!",
      "Fantastic!",
      "Exactly!",
      "You’re doing great!",
      "Superb!",
      "Keep it going!",
      "That’s the way!",
      "Impressive!",
      "Right on!",
      "You’re crushing it!",
      "Nice job!",
      "You got it!",
      "Amazing work!",
      "Outstanding!",
      "Brilliant!",
      "Good thinking!",
      "That’s the spirit!"
    ],
    "step_incorrect": [
      "Correct your answer",
      "Correct your work",
      "Correct the answer",
      "Fix the answer",
      "Fix this step",
      "Fix your answer",
      "Redo this step",
      "Redo the step",
      "Redo your answer",
      "Retry the step",
      "Retry this step",
      "Solve it again",
      "Solve this again",
      "Try again",
      "Try it again",
      "Try this again"
    ],
    "problem_incorrect": [
      "You'll have another chance at this later",
      "Marking this for review",
      "We’ll revisit this soon",
      "Let’s come back to this later",
      "Not yet—but you'll get it next time",
      "Saving this for another try"
    ]
  };

  static const Map<String, List<String>> emojis = {
    'problem_correct': [
      '🎉',
      '🎯',
      '✅',
      '⭐',
      '👏',
      '💯',
      '🙌',
      '🏆',
      '🚀',
      '🎈',
      '🥇',
      '😊',
      '👍',
      '🌟',
      '🔥',
      '🧠',
      '🍀',
      '💪',
      '🌈',
      '✨',
    ],
    'problem_incorrect': [
      '🕵️‍♂️',
      '🔍',
      '📖',
      '🔧',
      '🗒️',
      '💭',
      '🕰️',
      '🔬',
      '🧪',
      '🧱',
      '💬',
      '⏳',
    ],
  };

  static String getRandomFeedbackMessage({required String feedbackType}) {
    // Ensure feedback type is valid and exists in the map
    final messagesList = messages[feedbackType];
    if (messagesList != null && messagesList.isNotEmpty) {
      final randomIndex = Random().nextInt(messagesList.length);
      return messagesList[randomIndex];
    }

    // Fallback if feedbackType is invalid or none
    return "";
  }

  static String getRandomFeedbackEmoji({required String emojiType}) {
    // Ensure feedback type is valid and exists in the map
    final emojisList = emojis[emojiType];
    if (emojisList != null && emojisList.isNotEmpty) {
      final randomIndex = Random().nextInt(emojisList.length);
      return emojisList[randomIndex];
    }

    // Fallback if feedbackType is invalid or none
    return "";
  }
}
