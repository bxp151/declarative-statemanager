// file: step_log_dao.dart
import '../services/schema/database_table_service.dart';
import 'package:automath/models/step_log.dart';

class StepLogDao {
  // Singleton instance
  static final StepLogDao _instance = StepLogDao._internal();
  factory StepLogDao() => _instance;
  StepLogDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Insert a log entry
  Future<void> insertStepLog(StepLog log) async {
    final db = await _dbService.database; // Get database instance
    await db.insert('step_log', log.toMap()); // Use the model's toMap() here
  }
}
