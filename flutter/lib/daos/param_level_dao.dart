// file: param_level_dao.dart
import 'package:automath/models/param_level.dart';
import 'package:automath/services/schema/database_table_service.dart';

class ParamLevelDao {
  // Singleton instance
  static final ParamLevelDao _instance = ParamLevelDao._internal();
  factory ParamLevelDao() => _instance;
  ParamLevelDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Insert a log entry
  Future<void> insertParamLevelLog(ParamLevel log) async {
    final db = await _dbService.database; // Get database instance
    await db.insert(
        'param_level_log', log.toMap()); // Use the model's toMap() here
  }

  Future<ParamLevel> getDecisionParamLevel() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the most recent currentParamLevel
    final map = await db.rawQuery('''
    SELECT newLevel
    FROM decision_param_level_view
    ''');

    if (map.isNotEmpty && map.first['newLevel'] != null) {
      return ParamLevel(currentParamLevel: map.first['newLevel'] as int);
    } else {
      return await getCurrentParamLevel();
    }
  }

  Future<ParamLevel> getCurrentParamLevel() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the most recent currentParamLevel
    final map = await db.rawQuery('''
    SELECT currentParamLevel
    FROM param_level_log
    ORDER BY timestamp DESC
    LIMIT 1
  ''');

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      final firstRow = map.first;
      final objCurrentParamLevel = ParamLevel.fromMap(firstRow);
      return objCurrentParamLevel;
    } else {
      // else throw exception
      throw Exception('No paramLevel found');
    }
  }
}
