// File: session_log.dart

class SessionLog {
  final String date;
  final int sessionID;
  final int numSets;
  final int numCorrect;
  final int numIncorrect;
  final int numProblems;
  final double propCorrect;
  final double propIncorrect;
  final int timeTaken;
  final double timePerProblem;

  SessionLog({
    required this.date,
    required this.sessionID,
    required this.numSets,
    required this.numCorrect,
    required this.numIncorrect,
    required this.numProblems,
    required this.propCorrect,
    required this.propIncorrect,
    required this.timeTaken,
    required this.timePerProblem,
  });
}

