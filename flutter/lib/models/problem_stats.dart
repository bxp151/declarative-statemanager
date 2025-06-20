// File: problem_stats.dart

class ProblemStats {
  final String probText;
  final int correctSolves;
  final int incorrectSolves;
  final int totAttempts;  
  final double propCorrect;
  final double propIncorrect;
  final int totSolveTime;
  final double avgSolveTime;

  ProblemStats({
    required this.probText,
    required this.correctSolves,
    required this.incorrectSolves,
    required this.totAttempts,
    required this.propCorrect,
    required this.propIncorrect,
    required this.totSolveTime,
    required this.avgSolveTime
  }) ;
}