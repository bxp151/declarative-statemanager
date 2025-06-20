// file: process_log_dao.dart
import '../services/schema/database_table_service.dart';
// import 'package:automath/daos/step_stats_dao.dart';
import 'package:automath/daos/problem_log_dao.dart';
// import 'package:automath/daos/problem_stats_dao.dart';
// import 'package:automath/daos/set_log_dao.dart';
// import 'package:automath/daos/session_log_dao.dart';
// import 'package:automath/daos/date_log_dao.dart';

class ProcessLogDao {
  // Singleton instance
  static final ProcessLogDao _instance = ProcessLogDao._internal();
  factory ProcessLogDao() => _instance;
  ProcessLogDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  Future<void> upsertProcessLog(String processName) async {
    final db = await _dbService.database; // Get database instance
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.execute('''
      INSERT INTO process_log (processName, lastTimeStamp)
      VALUES (?, ?)
      ON CONFLICT(processName) DO UPDATE SET lastTimeStamp = excluded.lastTimeStamp;
    ''', [processName, now]);
  }

  Future<void> processLogsSequentially() async {
    // await StepStatsDao().updateStepLogs();
    await ProblemLogDao().summarizeStepLogToProblemLog();
    // await ProblemStatsDao().summarizeProblemLogToProblemStats();
    // await SetLogDao().summarizeProblemLogToSetLog();

    // Only run SessionLog if the set is complete
    // if (isLastProblemInSet) {
    //   await SessionLogDao().summarizeSetLogToSessionLog();
    //   await DateLogDao().summarizeSessionLogToDateLog();
    // }
  }
}
