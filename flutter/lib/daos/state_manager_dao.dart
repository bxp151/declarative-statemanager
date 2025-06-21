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
  Future<int> insertStateLogEntry({
    required String originWidget,
    required String originMethod,
    required String stateName,
    required String stateValue,
  }) async {
    final db = await _dbService.database;

    await db.insert(
      'state_log',
      {
        'originWidget': originWidget,
        'originMethod': originMethod,
        'stateName': stateName,
        'stateValue': stateValue,
      },
    );

    // await dumpInMemoryDbToFile();

    final stepLogID = await db.rawQuery('''
      SELECT max(stateLogID) as stepLogID
      FROM state_log;
    ''');

    return stepLogID.first['stepLogID'] as int;
  }

  // Uses the stateChangeTimestamp to update widget build stats & tine stamps
  Future<void> updateWidgetPostFrame(
      {required int stateLogID, required String widgetRebuildResult}) async {
    final db = await _dbService.database;
    int destinationTimestamp = DateTime.now().millisecondsSinceEpoch;

    await db.execute('''
      UPDATE state_log
      SET destinationTimestamp = ?, widgetRebuildResult = ?
      WHERE stateLogID = ?
    ''', [destinationTimestamp, widgetRebuildResult, stateLogID]);

    await dumpInMemoryDbToFile();
  }

  Future<void> updateDispatchTimestamp({required int stateLogID}) async {
    final db = await _dbService.database;
    int dispatchTimestamp = DateTime.now().millisecondsSinceEpoch;
    await db.execute('''
      UPDATE state_log
      SET dispatchTimestamp = ?
      WHERE stateLogID = ?
    ''', [dispatchTimestamp, stateLogID]);

    // await dumpInMemoryDbToFile();
  }

  // Get all rows matching minimum priority
  Future<List<Map<String, Object?>>> getStates() async {
    final db = await _dbService.database;
    final qryState = await db.rawQuery('''
    SELECT stateLogID,
          stateName,
          stateValue
      FROM state_log
    WHERE dispatchTimestamp IS NULL AND 
          originTimestamp = (
                                SELECT min(originTimestamp) as originTimestamp
                                  FROM state_log
                            );
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
    print("Vacuumed");
  }

  Future<String> getSimFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/state_snapshot.db';
  }
}
