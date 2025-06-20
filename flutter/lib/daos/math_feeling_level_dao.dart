// file: math_feeling_level_dao.dart

import 'package:automath/models/math_feeling_level.dart';
import 'package:automath/services/schema/database_table_service.dart';

class MathFeelingLevelDao {
  // Singleton instance
  static final MathFeelingLevelDao _instance = MathFeelingLevelDao._internal();
  factory MathFeelingLevelDao() => _instance;
  MathFeelingLevelDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Insert a log entry
  Future<void> insertMathFeelingLevelLog(MathFeelingLevel log) async {
    final db = await _dbService.database; // Get database instance
    await db.insert(
        'math_feeling_level_log', log.toMap()); // Use the model's toMap() here
  }

  Future<MathFeelingLevel> getCurrentMathFeelingLevel() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the most recent claimedProgressLevel
    final map = await db.rawQuery('''
    SELECT mathFeelingLevel
    FROM math_feeling_level_log
    ORDER BY timestamp DESC
    LIMIT 1
    ''');

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      // gets the first row from the query return
      final firstRow = map.first;
      // Converts the map to a model object
      final objMathFeelingLevel = MathFeelingLevel.fromMap(firstRow);
      return objMathFeelingLevel;
    } else {
      // Else throw an error
      throw Exception('No mathFeelingLevel found');
    }
  }
}
