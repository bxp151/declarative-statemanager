// File: problem_stats_dao.dart

import '../services/schema/database_table_service.dart';
import 'package:automath/models/problem_stats.dart';
import 'package:automath/daos/process_log_dao.dart';

class ProblemStatsDao {
  // Singleton instance
  static final ProblemStatsDao _instance = ProblemStatsDao._internal();
  ProblemStatsDao._internal();
  factory ProblemStatsDao() => _instance;

  final DatabaseTableService _dbservice = DatabaseTableService();

  // Aggregate the problem log entries
  Future<void> summarizeProblemLogToProblemStats() async {
    final db = await _dbservice.database;

    // Get all problem IDs that haven't been summarized yet
    final List<Map<String, dynamic>> qryProblemLog = await db.rawQuery('''
      SELECT probLogID, probText, isProblemCorrect, timeTaken
      FROM problem_log
      WHERE timeStamp > ( SELECT lastTimeStamp 
                          FROM process_log 
                          WHERE processName = 'summarizeProblemLogToProblemStats' )
    ''');

    // If the query is empty
    if (qryProblemLog.isEmpty) {
      await ProcessLogDao()
          .upsertProcessLog('summarizeProblemLogToProblemStats');
      return;
    }

    // Summarize each unsummarized problem ID
    for (var row in qryProblemLog) {
      //  Get previous problem stats
      final qryProbStats = await db.rawQuery('''
        SELECT correctSolves, incorrectSolves, totAttempts, totSolveTime
        FROM problem_stats
        WHERE probText = ?
      ''', [row['probText']]);

      final String probText = row['probText'];

      // if its not empty, take the first row, if it's empty assign 0 to each of the variable below
      final rowQryPrboStats = qryProbStats.isNotEmpty
          ? qryProbStats.first
          : {
              'correctSolves': 0,
              'incorrectSolves': 0,
              'totAttempts': 0,
              'totSolveTime': 0
            };

      //  Extract previous problem stats into variables
      final int previousCorrectSolves = rowQryPrboStats['correctSolves'] as int;
      final int previousIncorrectSolves =
          rowQryPrboStats['incorrectSolves'] as int;
      final int previousTotAttempts = rowQryPrboStats['totAttempts'] as int;
      final int previousTotSolveTime = rowQryPrboStats['totSolveTime'] as int;

      // Calculate current problem stats from problem_log query -- row
      final int currentCorrectSolves = row['isProblemCorrect'] as int;
      final int currentIncorrectSolves = row['isProblemCorrect'] == 1 ? 0 : 1;
      final int currentTotSolveTime = row['timeTaken'] as int;
      final int currentTotlAttempts = 1;

      // Add previous to current
      final int correctSolves = previousCorrectSolves + currentCorrectSolves;
      final int incorrectSolves =
          previousIncorrectSolves + currentIncorrectSolves;
      final int totlAttempts = previousTotAttempts + currentTotlAttempts;
      final int totSolveTime = previousTotSolveTime + currentTotSolveTime;

      // Create class object
      final logItem = ProblemStats(
          probText: probText,
          correctSolves: correctSolves,
          incorrectSolves: incorrectSolves,
          totAttempts: totlAttempts,
          propCorrect: correctSolves / totlAttempts,
          propIncorrect: incorrectSolves / totlAttempts,
          totSolveTime: totSolveTime,
          avgSolveTime: totSolveTime / totlAttempts);

      // Upsert logItem into DB
      upsertProblemStats(logItem);
    }

    // Update log processing timestamp
    await ProcessLogDao().upsertProcessLog('summarizeProblemLogToProblemStats');
  }

  Future<void> upsertProblemStats(ProblemStats log) async {
    final db = await _dbservice.database;

    await db.execute('''
      INSERT INTO problem_stats (probText, correctSolves, incorrectSolves, totAttempts, propCorrect, 
                                 propIncorrect, totSolveTime, avgSolveTime)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(probText) DO UPDATE SET 
          correctSolves = excluded.correctSolves, 
          incorrectSolves = excluded.incorrectSolves, 
          totAttempts = excluded.totAttempts, 
          propCorrect = excluded.propCorrect, 
          propIncorrect = excluded.propIncorrect, 
          totSolveTime = excluded.totSolveTime, 
          avgSolveTime = excluded.avgSolveTime
    ''', [
      log.probText,
      log.correctSolves,
      log.incorrectSolves,
      log.totAttempts,
      log.propCorrect,
      log.propIncorrect,
      log.totSolveTime,
      log.avgSolveTime
    ]);
  }
}
