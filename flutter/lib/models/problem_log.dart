// File: problem_dart

class ProblemLog {
  final int setID;
  final String probLogID;
  final String probID;
  final String queueName;
  final int priority;
  final int interventionLevel;
  final int overallLevel;
  final int gradeLevel;
  final int subLevelScore;
  final int paramLevelScore;
  final String probText;
  final String paramType;
  final int numSteps;
  final int numCorrectStepsFirstTry;
  final int numIncorrectStepsFirstTry;
  final int isProblemCorrect;
  final int isProblemTimely;
  final int isProblemFluent;
  final double propStepsCorrect;
  final double propStepsIncorrect;
  final int timeTaken;
  final double fluencyProblemTimeGap;

  ProblemLog({
    required this.setID,
    required this.probLogID,
    required this.probID,
    required this.queueName,
    required this.priority,
    required this.interventionLevel,
    required this.overallLevel,
    required this.gradeLevel,
    required this.subLevelScore,
    required this.paramLevelScore,
    required this.probText,
    required this.paramType,
    required this.numSteps,
    required this.numCorrectStepsFirstTry,
    required this.numIncorrectStepsFirstTry,
    required this.isProblemCorrect,
    required this.isProblemTimely,
    required this.isProblemFluent,
    required this.propStepsCorrect,
    required this.propStepsIncorrect,
    required this.timeTaken,
    required this.fluencyProblemTimeGap,
  });

  Map<String, dynamic> toMap() {
    return {
      'setID': setID,
      'probLogID': probLogID,
      'probID': probID,
      'queueName': queueName,
      'priority':priority,
      'interventionLevel': interventionLevel,
      'overallLevel': overallLevel,
      'gradeLevel': gradeLevel,
      'subLevelScore': subLevelScore,
      'paramLevelScore': paramLevelScore,
      'probText': probText,
      'paramType': paramType,
      'numSteps': numSteps,
      'numCorrectStepsFirstTry': numCorrectStepsFirstTry,
      'numIncorrectStepsFirstTry': numIncorrectStepsFirstTry,
      'isProblemCorrect': isProblemCorrect,
      'propStepsCorrect': propStepsCorrect,
      'propStepsIncorrect': propStepsIncorrect,
      'timeTaken': timeTaken,
      'fluencyProblemTimeGap': fluencyProblemTimeGap,
      'isProblemTimely': isProblemTimely,
      'isProblemFluent': isProblemFluent,
    };
  }
}
