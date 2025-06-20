// file: step_log_dao.dart
import '../services/schema/database_table_service.dart';

class UserPerformanceDao {
  // Singleton instance
  static final UserPerformanceDao _instance = UserPerformanceDao._internal();
  factory UserPerformanceDao() => _instance;
  UserPerformanceDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // gets the lates problem from the problem_log
  Future<String> getLatestProblemLogID() async {
    final db = await _dbService.database;

    final row = await db.rawQuery("""
      SELECT probLogID FROM problem_log
      ORDER BY timestamp DESC
      LIMIT 1;
    """);

    return row.first['probLogID'].toString(); // returns a row of data
  }

  // gets the problem from the problem_log
  Future<List<Map<String, dynamic>>> getProblemData(
      String evaluationItemID) async {
    final db = await _dbService.database;

    final row = await db.rawQuery("""
      SELECT * FROM problem_log
      WHERE probLogID = ?
    """, [evaluationItemID]);

    return row; // returns a row of data
  }

  // gets the last problem steps from the step_log
  Future<List<Map<String, dynamic>>> getLastProblemStepData(
      String probID) async {
    final db = await _dbService.database;

    final row = await db.rawQuery("""
      SELECT * FROM step_log
      WHERE probLogID = ?;
    """, [probID]);

    return row; // returns a row of data
  }

  // Insert a log entry
  // Future<void> insertStepLog(StepLog log) async {
  //   // Get database instance
  //   final db = await _dbService.database; // Get database instance

  //   // Prepare data as a map
  //   final logData = {
  //     'probID': log.probID,
  //     'probText': log.probText,
  //     'numSteps': log.numSteps,
  //     'stepNo': log.stepNo,
  //     'stepCalc': log.stepCalc,
  //     'attempt': log.attempt,
  //     'evalStatus': log.evalStatus,
  //     'timeTaken': log.timeTaken
  //   };

  //   // Insert data into 'logs' table
  //   await db.insert('step_log', logData);
  // }
}
