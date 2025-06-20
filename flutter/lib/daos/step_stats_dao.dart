// file: step_stats_dao.dart
import '../services/schema/database_table_service.dart';
import 'process_log_dao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:automath/models/step_stats..dart';
import 'package:automath/constants/fluency_targets.dart';

class StepStatsDao {
  // Singleton instance
  static final StepStatsDao _instance = StepStatsDao._internal();
  factory StepStatsDao() => _instance;
  StepStatsDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Update step logs (summarize) at the end of a problem
  Future<void> updateStepLogs() async {
    // select unique probLogID from step_log
    final db = await _dbService.database;

    // Need to filter based on the last time logs were aggregated
    final qryProbID = await db.rawQuery('''
      select DISTINCT probLogID, stepCalc
      from step_log
      where timestamp > 
        (select lastTimeStamp 
        from process_log 
        where processName = 'summarizeStepLogToStats') 
    ''');

    // If the query is empty
    if (qryProbID.isEmpty) {
      await ProcessLogDao().upsertProcessLog('summarizeStepLogToStats');
      return;
    }

    for (var row in qryProbID) {
      final probLogID = row['probLogID'].toString();
      final stepCalc = row['stepCalc'].toString();
      final stepSummary = await summarizeSteps(
          probLogID, stepCalc); //combines previous with current StepLog entries
      await upsertStepStats(stepSummary);
    }

    // Update the processing metadata table timestamp
    await ProcessLogDao().upsertProcessLog("summarizeStepLogToStats");
  }

  // returns correctAttempts incorrectAttempts totAttempts (previous + current)
  Future<StepStats> summarizeSteps(String probLogID, String stepCalc) async {
    final db = await _dbService.database;

    final qryStats = await db.rawQuery('''
        select correctAttempts, incorrectAttempts, totAttempts
        from step_stats
        where stepCalc = ?
    ''', [stepCalc]);

    final row = qryStats.isNotEmpty
        ? qryStats.first
        : {'correctAttempts': 0, 'incorrectAttempts': 0, 'totAttempts': 0};

    int previousCorrectAttempts = row['correctAttempts'] as int;
    int previousIncorrectAttempts = row['incorrectAttempts'] as int;

    // Correct attempts - query step_log by probLogID
    final qryCorrectAttempts = await db.rawQuery('''
      SELECT COUNT(*)
      FROM step_log
      WHERE probLogID = ? AND evalStatus = ?
    ''', [probLogID, 'step_correct']);

    int currentCorrectAttempts = Sqflite.firstIntValue(qryCorrectAttempts) ?? 0;

    // Incorrect attempts - query step_log by probLogID
    final qryIncorrectAttempts = await db.rawQuery('''
      SELECT COUNT(*)
      FROM step_log
      WHERE probLogID = ? AND evalStatus = ?
    ''', [probLogID, 'step_incorrect']);

    int currentIncorrectAttempts =
        Sqflite.firstIntValue(qryIncorrectAttempts) ?? 0;

    // Combine previous and current attempt
    int correctAttempts = currentCorrectAttempts + previousCorrectAttempts;
    int incorrectAttempts =
        currentIncorrectAttempts + previousIncorrectAttempts;
    int totAttempts = correctAttempts + incorrectAttempts;

    // Total time totTime
    final qryTotTime = await db.rawQuery('''
      SELECT SUM(COALESCE(timeTaken,0))
      FROM step_log
      WHERE probLogID = ?
    ''', [probLogID]);

    int totTime = Sqflite.firstIntValue(qryTotTime) ?? 0;

    double timePerStep = totTime / totAttempts;

    return StepStats(
      stepCalc: stepCalc,
      correctAttempts: previousCorrectAttempts + correctAttempts,
      incorrectAttempts: previousIncorrectAttempts + incorrectAttempts,
      totAttempts: totAttempts,
      propIncorrect: incorrectAttempts / totAttempts,
      propCorrect: correctAttempts / totAttempts,
      totTime: totTime,
      timePerStep: timePerStep,
      avgFluencyStepTimeGap: kMaxFluentStepSeconds - timePerStep,
    );
  }

  // Upsert step stats
  Future<void> upsertStepStats(StepStats stepSummary) async {
    final db = await _dbService.database;

    await db.execute('''
      INSERT INTO step_stats (stepCalc, correctAttempts, incorrectAttempts, totAttempts, propIncorrect, 
                              propCorrect, totTime, timePerStep, avgFluencyStepTimeGap)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(stepCalc) DO UPDATE SET
        correctAttempts = excluded.correctAttempts,
        incorrectAttempts = excluded.incorrectAttempts,
        totAttempts = excluded.totAttempts,
        propIncorrect = excluded.propIncorrect,
        propCorrect = excluded.propCorrect,
        totTime = excluded.totTime,
        timePerStep = excluded.timePerStep;
        avgFluencyStepTimeGap = excluded.avgFluencyStepTimeGap;
    ''', [
      stepSummary.stepCalc,
      stepSummary.correctAttempts,
      stepSummary.incorrectAttempts,
      stepSummary.totAttempts,
      stepSummary.propIncorrect,
      stepSummary.propCorrect,
      stepSummary.totTime,
      stepSummary.timePerStep,
      stepSummary.avgFluencyStepTimeGap,
    ]);
  }
}
