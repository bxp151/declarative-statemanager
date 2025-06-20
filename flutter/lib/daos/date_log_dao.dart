// file: set_log_dao.dart
import 'package:automath/daos/process_log_dao.dart';
import 'package:automath/models/date_log.dart';
import '../services/schema/database_table_service.dart';

class DateLogDao {
  // Singleton instance
  static final DateLogDao _instance = DateLogDao._internal();
  factory DateLogDao() => _instance;
  DateLogDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  Future<void> summarizeSessionLogToDateLog() async {
    final db = await _dbService.database; // Get database instance

    // Query and summarize session log where timestamp > process_log
    final qrySessionLog = await db.rawQuery('''
      SELECT 
        date, 
        COUNT(*) AS numSessions, 
        SUM(numProblems) AS numProblems, 
        SUM(numCorrect) AS numCorrect, 
        SUM(numIncorrect) AS numIncorrect, 
        SUM(timeTaken) AS timeTaken,
        CASE 
          WHEN SUM(numProblems) > 0 THEN SUM(numCorrect) * 1.0 / SUM(numProblems) 
          ELSE 0 
        END AS propCorrect,
        CASE 
          WHEN SUM(numProblems) > 0 THEN SUM(numIncorrect) * 1.0 / SUM(numProblems) 
          ELSE 0 
        END AS propIncorrect,
        CASE
          WHEN SUM(timeTaken) > 0 THEN SUM(timeTaken) * 1.0 / SUM(numProblems)
          ELSE 0
        END as timePerProblem
      FROM session_log
      WHERE timestamp > (SELECT lastTimeStamp 
                        FROM process_log 
                        WHERE processName = 'summarizeSessionLogToDateLog')
      GROUP BY date;
      ''');

    // If the query is empty
    if (qrySessionLog.isEmpty) {
      await ProcessLogDao().upsertProcessLog('summarizeSessionLogToDateLog');
      return;
    }

    // for each row in the query
    // Loop through query results
    for (var row in qrySessionLog) {
      final logItem = DateLog(
        date: row['date'].toString(),
        numSessions: int.parse(row['numSessions'].toString()),
        numProblems: int.parse(row['numProblems'].toString()),
        numCorrect: int.parse(row['numCorrect'].toString()),
        numIncorrect: int.parse(row['numIncorrect'].toString()),
        propCorrect: double.parse(row['propCorrect'].toString()),
        propIncorrect: double.parse(row['propIncorrect'].toString()),
        timeTaken: int.parse(row['timeTaken'].toString()),
        timePerProblem: double.parse(row['timePerProblem'].toString()),
      );
      // Call Upsert
      await upsertDateLog(logItem);

      // update process_log
      await ProcessLogDao().upsertProcessLog('summarizeSessionLogToDateLog');
    }
  }

  Future<void> upsertDateLog(DateLog log) async {
    final db = await _dbService.database; // Get database instance

    await db.execute("""
      INSERT INTO date_log (date, numSessions, numCorrect, numIncorrect, numProblems, propCorrect, propIncorrect, timeTaken, timePerProblem) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(date) DO UPDATE SET 
        numSessions = excluded.numSessions,
        numCorrect = excluded.numCorrect,
        numIncorrect = excluded.numIncorrect,
        numProblems = excluded.numProblems,
        propCorrect = excluded.propCorrect,
        propIncorrect = excluded.propIncorrect,
        timeTaken = excluded.timeTaken,
        timePerProblem = excluded.timePerProblem,
        timestamp = strftime('%s', 'now') * 1000; -- Explicitly update timestamp
    """, [
      log.date,
      log.numSessions,
      log.numCorrect,
      log.numIncorrect,
      log.numProblems,
      log.propCorrect,
      log.propIncorrect,
      log.timeTaken,
      log.timePerProblem
    ]);
  }
}
