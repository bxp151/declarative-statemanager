// File: step_stats.dart

class StepStats {
  final String stepCalc;
  final int correctAttempts;
  final int incorrectAttempts;
  final int totAttempts;
  final double propIncorrect;
  final double propCorrect;
  final int totTime;
  final double timePerStep;
  final double avgFluencyStepTimeGap;

  StepStats({
    required this.stepCalc,
    required this.correctAttempts,
    required this.incorrectAttempts,
    required this.totAttempts,
    required this.propIncorrect,
    required this.propCorrect,
    required this.totTime,
    required this.timePerStep,
    required this.avgFluencyStepTimeGap,
  });
}
