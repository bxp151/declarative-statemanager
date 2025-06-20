import 'dart:convert';

class ProblemData {
  final String queueName;
  final int priority;
  final int interventionLevel;
  final int quickSolveFlag;
  final String probID;
  final int overallLevel;
  final int gradeLevel;
  final int subLevelScore;
  final int paramLevelScore;
  final String probText;
  final double answer;
  final Map<String, dynamic> stepHuman;
  final Map<String, dynamic> stepMap;
  final Map<String, dynamic> solvedGrid;
  final String instanceID;
  final String paramType;
  final String paramNum;
  final int numParameters;
  final int numSteps;
  final Map<String, dynamic> paramGrid;
  final Map<String, dynamic> stepsToParams;

  ProblemData({
    required this.queueName,
    required this.priority,
    required this.interventionLevel,
    required this.quickSolveFlag,
    required this.probID,
    required this.overallLevel,
    required this.gradeLevel,
    required this.subLevelScore,
    required this.paramLevelScore,
    required this.probText,
    required this.answer,
    required this.stepHuman,
    required this.stepMap,
    required this.solvedGrid,
    required this.instanceID,
    required this.paramType,
    required this.paramNum,
    required this.numParameters,
    required this.numSteps,
    required this.paramGrid,
    required this.stepsToParams,
  });

  factory ProblemData.fromMap(Map<String, dynamic> map) {
    return ProblemData(
      queueName: map['queueName'],
      priority: map['priority'],
      interventionLevel: map['interventionLevel'],
      quickSolveFlag: map['quickSolveFlag'],
      probID: map['probID'],
      overallLevel: map['overallLevel'],
      gradeLevel: map['gradeLevel'],
      subLevelScore: map['subLevelScore'],
      paramLevelScore: map['paramLevelScore'],
      probText: map['probText'],
      answer: map['answer'],
      stepHuman: jsonDecode(map['stepHuman']),
      stepMap: jsonDecode(map['stepMap']),
      solvedGrid: jsonDecode(map['solvedGrid']),
      instanceID: map['instanceID'],
      paramType: map['paramType'],
      paramNum: map['paramNum'],
      numParameters: map['numParameters'],
      numSteps: map['numSteps'],
      paramGrid: jsonDecode(map['paramGrid']),
      stepsToParams: jsonDecode(map['stepsToParams']),
    );
  }
}
