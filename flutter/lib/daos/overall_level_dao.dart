// file: overall_level_dao.dart
import 'package:automath/models/overall_level.dart';
import 'package:automath/services/schema/database_table_service.dart';

class OverallLevelDao {
  // Singleton instance
  static final OverallLevelDao _instance = OverallLevelDao._internal();
  factory OverallLevelDao() => _instance;
  OverallLevelDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Insert a log entry
  Future<void> insertOverallLevelLog(OverallLevel log) async {
    final db = await _dbService.database; // Get database instance
    await db.insert(
        'overall_level_log', log.toMap()); // Use the model's toMap() here
  }

  /// Gets the overall level from the decision table
  Future<OverallLevel> getDecisionOverallLevel() async {
    final db = await _dbService.database; // Get database instance
    final map = await db.rawQuery('''
    SELECT newLevel
    FROM decision_overall_level_view
    ''');

    if (map.isNotEmpty && map.first['newLevel'] != null) {
      return OverallLevel(currentOverallLevel: map.first['newLevel'] as int);
    } else {
      return await getCurrentOverallLevel(); // fallback or default
    }
  }

  Future<OverallLevel> getCurrentOverallLevel() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the most recent currentOverallLevel
    final map = await db.rawQuery('''
    SELECT currentOverallLevel
    FROM overall_level_log
    ORDER BY timestamp DESC
    LIMIT 1
    ''');

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      final firstRow = map.first;
      final objCurrentOverallLevel = OverallLevel.fromMap(firstRow);
      return objCurrentOverallLevel;
    } else {
      throw Exception('No overallLevel found');
    }
  }

  Future<int> getFirstOverallLevelFromGradeLevel(
      {required int gradeLevel}) async {
    // Delete this later
    if (gradeLevel > 3) gradeLevel = 3;

    final db = await _dbService.database; // Get database instance
    // Query to get the most recent currentOverallLevel
    final map = await db.rawQuery('''
    SELECT overallLevel
    FROM grade_level_to_first_overall_level
    WHERE gradeLevel = ?
    ''', [gradeLevel]);

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      final firstRow = map.first;
      final firstOverallLevel = firstRow['overallLevel'] as int;
      return firstOverallLevel;
    }

    // Fallback return to satisfy the function signature
    throw Exception('No overallLevel found for gradeLevel $gradeLevel');
  }
}
