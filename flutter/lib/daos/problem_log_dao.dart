// File: problem_log_dao.dart

//import 'dart:js_interop';
import '../services/schema/database_table_service.dart';
import 'package:automath/models/problem_log.dart';
import 'package:automath/utils/helpers.dart';
import 'package:sqflite/sqflite.dart';
import 'package:automath/daos/process_log_dao.dart';
import 'package:automath/managers/set_manager.dart';
import 'package:automath/constants/fluency_targets.dart';

class ProblemLogDao {
  // Singleton instance
  static final ProblemLogDao _instance = ProblemLogDao._internal();
  ProblemLogDao._internal();
  factory ProblemLogDao() => _instance;

  final DatabaseTableService _dbservice = DatabaseTableService();

  // Aggregate the step log entries at a problem level
  Future<void> summarizeStepLogToProblemLog() async {
    final db = await _dbservice.database;

    // Get features that don't change
    final qryProbID = await db.rawQuery('''
      SELECT DISTINCT probLogID,  probID, queueName, priority, interventionLevel, overallLevel, gradeLevel, subLevelScore, 
      paramLevelScore, probText, paramType, numSteps
      FROM step_log
      WHERE timestamp > (
        SELECT lastTimeStamp
        FROM process_log
        WHERE processName = 'summarizeStepLogToProblemLog'
        )
    ''');

    // If the query is empty
    if (qryProbID.isEmpty) {
      await ProcessLogDao().upsertProcessLog('summarizeStepLogToProblemLog');
      return;
    }

    for (var row in qryProbID) {
      final probLogID = row['probLogID'];
      final probID = row['probID'];
      final queueName = row['queueName'];
      final priority = row['priority'];
      final interventionLevel = row['interventionLevel'];
      final overallLevel = row['overallLevel'] as int;
      final gradeLevel = row['gradeLevel'] as int;
      final subLevelScore = row['subLevelScore'] as int;
      final paramLevelScore = row['paramLevelScore'] as int;
      final probText = row['probText'] as String;
      final paramType = row['paramType'] as String;
      final numSteps = row['numSteps'] as int;

      // aggregate numCorrectStepsFirstTry
      final qryNumCorrectStepsFirstTry = await db.rawQuery('''
      	SELECT SUM(count) 
	      FROM (
	        SELECT COUNT(*) as count 
	        FROM step_log 
	        WHERE probLogID = ?
	          AND evalStatus = ?
	          AND Attempt = 1 
        GROUP BY StepNo
        )
      ''', [probLogID, 'step_correct']);

      int numCorrectStepsFirstTry =
          Helpers.extractIntResult(qryNumCorrectStepsFirstTry);

      // sum timeTaken
      final qryTimeTaken = await db.rawQuery('''
        SELECT sum(timeTaken)
        FROM step_log
        WHERE probLogID = ?
        ''', [probLogID]);

      int timeTaken = Helpers.extractIntResult(qryTimeTaken);

      print(
          "numCorrectStepsFirstTry: $numCorrectStepsFirstTry  |  timeTaken: $timeTaken");

      // (2) Store in ProblemLog Class and derive these
      final numIncorrectStepsFirstTry = numSteps - numCorrectStepsFirstTry;

      final fluencyProblemTimeGap =
          kMaxFluentStepSeconds * numSteps - timeTaken;

      final isProblemTimely = fluencyProblemTimeGap >= 0 ? 1 : 0;
      final isProblemCorrect = numIncorrectStepsFirstTry == 0 ? 1 : 0;
      final isProblemFluent =
          (isProblemCorrect == 1 && isProblemTimely == 1) ? 1 : 0;

      final logItem = ProblemLog(
          setID: SetManager().setID,
          probLogID: probLogID.toString(),
          probID: probID.toString(),
          queueName: queueName.toString(),
          priority: priority as int,
          interventionLevel: interventionLevel as int,
          overallLevel: overallLevel,
          gradeLevel: gradeLevel,
          subLevelScore: subLevelScore,
          paramLevelScore: paramLevelScore,
          probText: probText,
          paramType: paramType,
          numSteps: numSteps,
          numCorrectStepsFirstTry: numCorrectStepsFirstTry,
          numIncorrectStepsFirstTry: numIncorrectStepsFirstTry,
          isProblemCorrect: isProblemCorrect,
          propStepsCorrect: numCorrectStepsFirstTry / numSteps,
          propStepsIncorrect: numIncorrectStepsFirstTry / numSteps,
          timeTaken: timeTaken,
          fluencyProblemTimeGap: fluencyProblemTimeGap,
          isProblemTimely: isProblemTimely,
          isProblemFluent: isProblemFluent);

      // (3) Call insert method
      await upnsertProblemLog(logItem);
    }

    // update process metadata table
    await ProcessLogDao().upsertProcessLog('summarizeStepLogToProblemLog');
  }

  Future<void> upnsertProblemLog(ProblemLog log) async {
    final db = await _dbservice.database;
    await db.insert(
      'problem_log',
      log.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // This ensures upsert behavior
    );
  }

  Future<void> updateProblemAttemptLog({required String instanceID}) async {
    final db = await _dbservice.database;
    await db.execute('''
      UPDATE problem_attempt_log
      SET 
        numTimesCompleted = numTimesCompleted + 1,
        lastServedTimestamp = (strftime('%s', 'now') * 1000)
      WHERE instanceID = ?
    ''', [instanceID]);
  }
}
