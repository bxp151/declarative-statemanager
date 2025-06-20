// File: set_log.dart

class SetLog {
  final String date;
  final int sessionID;
  final int setID;
  final int numCorrect;
  final int numIncorrect;
  final int numProblems;
  final double propCorrect;
  final double propIncorrect;
  final int timeTaken;
  final double timePerProblem;

  SetLog({
    required this.date,
    required this.sessionID,
    required this.setID,
    required this.numCorrect,
    required this.numIncorrect,
    required this.numProblems,
    required this.propCorrect,
    required this.propIncorrect,
    required this.timeTaken,
    required this.timePerProblem
  }) ;
}
