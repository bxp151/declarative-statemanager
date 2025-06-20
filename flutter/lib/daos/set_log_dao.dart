// file: set_log_dao.dart
import 'package:automath/daos/process_log_dao.dart';
import '../services/schema/database_table_service.dart';
import 'package:automath/models/set_log.dart';
import 'package:automath/managers/session_manager.dart';
import 'package:automath/managers/set_manager.dart';
import 'package:automath/utils/helpers.dart';

class SetLogDao {
  // Singleton instance
  static final SetLogDao _instance = SetLogDao._internal();
  factory SetLogDao() => _instance;
  SetLogDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  Future<void> summarizeProblemLogToSetLog() async {
    final db = await _dbService.database; // Get database instance
    final int sessionID = SessionManager().sessionID;
    final int setID = SetManager().setID;
    final String date = Helpers().getCurrentDate();

    // Get all problem IDs that haven't been summarized yet
    final qryProblemLog = await db.rawQuery('''
      SELECT probLogID, isProblemCorrect, timeTaken
      FROM problem_log
      WHERE setID = ? AND timeStamp > ( SELECT lastTimeStamp 
                          FROM process_log 
                          WHERE processName = 'summarizeProblemLogToSetLog' )
    ''', [setID]);

    // If the query is empty
    if (qryProblemLog.isEmpty) {
      await ProcessLogDao().upsertProcessLog('summarizeProblemLogToSetLog');
      return;
    }

    // for each probID sum current and previous values and store in set_log
    for (var row in qryProblemLog) {
      // query previous values
      final qrySetLog = await db.rawQuery('''
        SELECT numCorrect, numIncorrect, numProblems, timeTaken
        FROM set_log
        WHERE sessionID = ? AND setID = ? AND date = ?
      ''', [sessionID, setID, date]);

      // if empty, make 0, otherwise take frist row
      final rowSetLogQry = qrySetLog.isNotEmpty
          ? qrySetLog.first
          : {
              'numCorrect': 0,
              'numIncorrect': 0,
              'numProblems': 0,
              'timeTaken': 0
            };

      // set values as previous values
      final previousNumCorrect = rowSetLogQry['numCorrect'] as int;
      final previousNumIncorrect = rowSetLogQry['numIncorrect'] as int;
      final previousNumProblems = rowSetLogQry['numProblems'] as int;
      final previousTimeTaken = rowSetLogQry['timeTaken'] as int;

      // set current values from qryProblemLog
      final currentNumCorrect = row['isProblemCorrect'] == 1 ? 1 : 0;
      final currentNumIncorrect = row['isProblemCorrect'] == 0 ? 1 : 0;
      final currentNumProblems = 1;
      final currentTimeTaken = row['timeTaken'] as int;

      // add previous to current
      final numCorrect = previousNumCorrect + currentNumCorrect;
      final numIncorrect = previousNumIncorrect + currentNumIncorrect;
      final numProblems = previousNumProblems + currentNumProblems;
      final timeTaken = previousTimeTaken + currentTimeTaken;

      // Create class instance
      final logItem = SetLog(
          date: date,
          sessionID: sessionID,
          setID: setID,
          numCorrect: numCorrect,
          numIncorrect: numIncorrect,
          numProblems: numProblems,
          propCorrect: numCorrect / numProblems,
          propIncorrect: numIncorrect / numProblems,
          timeTaken: timeTaken,
          timePerProblem: timeTaken / numProblems);

      // upsert to the set log
      await upsertSetLog(logItem);
    }

    // update process_log
    await ProcessLogDao().upsertProcessLog('summarizeProblemLogToSetLog');
  }

  Future<void> upsertSetLog(SetLog log) async {
    final db = await _dbService.database; // Get database instance

    await db.execute("""
        INSERT INTO set_log (sessionID, setID, date, numCorrect, numIncorrect, numProblems, propCorrect, propIncorrect, timeTaken, timePerProblem) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(sessionID, setID, date) DO UPDATE SET 
          numCorrect = excluded.numCorrect,
          numIncorrect = excluded.numIncorrect,
          numProblems = excluded.numProblems,
          propCorrect = excluded.propCorrect,
          propIncorrect = excluded.propIncorrect,
          timeTaken = excluded.timeTaken,
          timePerProblem = excluded.timePerProblem,
          timestamp = strftime('%s', 'now') * 1000; -- Explicitly update timestamp
      """, [
      log.sessionID,
      log.setID,
      log.date, // Explicitly pass the date field
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
