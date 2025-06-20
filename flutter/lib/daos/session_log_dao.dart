// file: set_log_dao.dart
import 'package:automath/daos/process_log_dao.dart';
import '../services/schema/database_table_service.dart';
import 'package:automath/models/session_log.dart';

class SessionLogDao {
  // Singleton instance
  static final SessionLogDao _instance = SessionLogDao._internal();
  factory SessionLogDao() => _instance;
  SessionLogDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  Future<void> summarizeSetLogToSessionLog() async {
    final db = await _dbService.database;

    // query to sum and group by date and session ID
    final qrySetLog = await db.rawQuery('''
      SELECT date, sessionID, count(*) as numSets, SUM(numCorrect) AS numCorrect, SUM(numIncorrect) AS numIncorrect, SUM(numProblems) AS numProblems, SUM(timeTaken) AS timeTaken
      FROM set_log
      WHERE timestamp > (SELECT lastTimeStamp 
                         FROM process_log 
                         WHERE processName = 'summarizeSetLogToSessionLog')
      GROUP BY date, sessionID
      ORDER BY date, sessionID;
    ''');

    // If the query is empty
    if (qrySetLog.isEmpty) {
      await ProcessLogDao().upsertProcessLog('summarizeSetLogToSessionLog');
      return;
    }

    // for each row in qrySetLog

    for (var row in qrySetLog) {
      final int numCorrect = int.parse(row['numCorrect'].toString());
      final int numIncorrect = int.parse(row['numIncorrect'].toString());
      final int numProblems = int.parse(row['numProblems'].toString());
      final int timeTaken = int.parse(row['timeTaken'].toString());

      // Assign values to the SessionLog object
      final logItem = SessionLog(
          date: row['date'].toString(),
          sessionID: int.parse(row['sessionID'].toString()),
          numSets: int.parse(row['numSets'].toString()),
          numCorrect: numCorrect,
          numIncorrect: numIncorrect,
          numProblems: numProblems,
          propCorrect: numCorrect / numProblems,
          propIncorrect: numIncorrect / numProblems,
          timeTaken: timeTaken,
          timePerProblem: timeTaken / numProblems);

      // upsert
      await upsertSessionLog(logItem);

      // update timestamp
      await ProcessLogDao().upsertProcessLog('summarizeSetLogToSessionLog');
    }
  }

  Future<void> upsertSessionLog(SessionLog log) async {
    final db = await _dbService.database; // Get database instance

    await db.execute("""
        INSERT INTO session_log (date, sessionID, numSets, numCorrect, numIncorrect, numProblems, propCorrect, propIncorrect, timeTaken, timePerProblem) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(date, sessionID) DO UPDATE SET 
          numSets = excluded.numSets,
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
      log.sessionID,
      log.numSets,
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
