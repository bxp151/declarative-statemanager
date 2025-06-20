// file: state_manager_dao.dart
import 'package:demo/services/database_table_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StateManagerDao {
  // Singleton instance
  static final StateManagerDao _instance = StateManagerDao._internal();
  factory StateManagerDao() => _instance;
  StateManagerDao._internal();

  final DatabaseTableService _dbService = DatabaseTableService();

  // Insert a state log entry
  Future<void> insertStateLogEntry(String stateName, dynamic stateValue) async {
    final db = await _dbService.database;

    await db.insert(
      'state_log',
      {'stateName': stateName, 'stateValue': stateValue},
    );
    await dumpInMemoryDbToFile();
  }

  // Uses the stateChangeTimestamp to update widget build stats & tine stamps
  Future<void> upsertWidgetBuildStatusAndTimestamp({
    required String stateName,
  }) async {
    final db = await _dbService.database;

    // Get earlies stateChangeTimestamp from state_view
    final qryResult = await db.rawQuery('''
    SELECT MIN(stateChangeTimestamp) AS minTimestamp
    FROM state_view
    WHERE stateName = ?
    ''', [stateName]);

    final stateChangeTimestamp = qryResult.first['minTimestamp'];

    const buildStatus = "built";
    int widgetDispatchTimestamp = DateTime.now().millisecondsSinceEpoch;

    await db.execute('''
      UPDATE state_log
      SET buildStatus = ?, widgetDispatchTimestamp = ?
      WHERE stateName = ? AND stateChangeTimestamp = ?
    ''', [
      buildStatus,
      widgetDispatchTimestamp,
      stateName,
      stateChangeTimestamp
    ]);

    await dumpInMemoryDbToFile();
  }

  // Get all rows matching minimum priority
  Future<List<Map<String, Object?>>> getStates() async {
    final db = await _dbService.database;
    final qryState = await db.rawQuery('''
    SELECT stateName, stateValue
    FROM state_view
    WHERE priority = (
      SELECT MIN(priority) FROM state_view
    )
    ORDER BY stateChangeTimestamp
    ''');

    return qryState;
  }

  Future<void> dumpInMemoryDbToFile() async {
    final inMemoryDb = await _dbService.database;
    final filePath = await getSimFilePath();

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete(); // ⬅️ This line forces overwrite
    }

    await inMemoryDb.execute("VACUUM INTO '$filePath'");
  }

  Future<String> getSimFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/state_snapshot.db';
  }
}
