// File: date_log.dart

class DateLog {
  final String date;
  final int numSessions;
  final int numProblems;
  final int numCorrect;
  final int numIncorrect;
  final double propCorrect;
  final double propIncorrect;
  final int timeTaken;
  final double timePerProblem;

  DateLog({
    required this.date,
    required this.numSessions,
    required this.numProblems,
    required this.numCorrect,
    required this.numIncorrect,
    required this.propCorrect,
    required this.propIncorrect,
    required this.timeTaken,
    required this.timePerProblem,
  });
}
