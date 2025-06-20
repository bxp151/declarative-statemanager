// File: step__log.dart

class StepLog {

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
  final int stepNo;
  final String stepCalc;
  final int attempt;
  final String evalStatus;
  final int timeTaken;
  final double fluencyStepTimeGap;
  final int? timestamp;

  StepLog({
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
    required this.stepNo,
    required this.stepCalc,
    required this.attempt,
    required this.evalStatus,
    required this.timeTaken,
    required this.fluencyStepTimeGap,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
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
      'stepNo': stepNo,
      'stepCalc': stepCalc,
      'attempt': attempt,
      'evalStatus': evalStatus,
      'timeTaken': timeTaken,
      'fluencyStepTimeGap': fluencyStepTimeGap,
    };
  }

  factory StepLog.fromMap(Map<String, dynamic> map) {
  return StepLog(
    probLogID: map['probLogID'],
    probID: map['probID'],
    queueName: map['queueName'],
    priority: map['priority'],
    interventionLevel: map['interventionLevel'],
    overallLevel: map['overallLevel'],
    gradeLevel: map['gradeLevel'],
    subLevelScore: map['subLevelScore'],
    paramLevelScore: map['paramLevelScore'],
    probText: map['probText'],
    paramType: map['paramType'],
    numSteps: map['numSteps'],
    stepNo: map['stepNo'],
    stepCalc: map['stepCalc'],
    attempt: map['attempt'],
    evalStatus: map['evalStatus'],
    timeTaken: map['timeTaken'],
    fluencyStepTimeGap: map['fluencyStepTimeGap'],
    timestamp: map['timestamp'],
  );
}

}
