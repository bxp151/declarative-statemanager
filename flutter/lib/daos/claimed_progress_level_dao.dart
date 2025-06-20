// file: claimed_progress_level_dao.dart
import 'package:automath/models/claimed_progress_level.dart';
import 'package:automath/services/schema/database_table_service.dart';

class ClaimedProgressLevelDao {
  // Singleton instance
  static final ClaimedProgressLevelDao _instance =
      ClaimedProgressLevelDao._internal();
  factory ClaimedProgressLevelDao() => _instance;
  ClaimedProgressLevelDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  // Insert a log entry
  Future<void> insertClaimedProgressLevelLog(ClaimedProgressLevel log) async {
    final db = await _dbService.database; // Get database instance
    await db.insert('claimed_progress_level_log',
        log.toMap()); // Use the model's toMap() here
  }

  Future<ClaimedProgressLevel> getCurrentClaimedProgressLevel() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the most recent claimedProgressLevel
    final map = await db.rawQuery('''
    SELECT claimedProgressLevel
    FROM claimed_progress_level_log
    ORDER BY timestamp DESC
    LIMIT 1
    ''');

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      // gets the first row from the query return
      final firstRow = map.first;
      // Converts the map to a model object
      final objClaimedProgressLevel = ClaimedProgressLevel.fromMap(firstRow);
      return objClaimedProgressLevel;
    } else {
      // Else throw an error
      throw Exception('No claimedProgressLevel found');
    }
  }
}
