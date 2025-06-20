// file: database_view_serivce.dart

import 'package:sqflite/sqflite.dart';
import 'package:automath/services/database_creation_service.dart';

class DatabaseViewService {
  DatabaseViewService._internal();

  static final DatabaseViewService _instance = DatabaseViewService._internal();

  factory DatabaseViewService() => _instance;

  Database? _database;

  Future<void> onCreate(Database db, int version) {
    return _onCreate(db, version);
  }

  Future<void> _onCreate(Database db, int version) async {}

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      'app_database.db',
      version: 1,
      onCreate: DatabaseCreationService().onCreate,
    );

    return _database!;
  }

  Future<void> createOrReplaceViews(Database db) async {
    await createStateView(db);
    // await createStateQueueView(db);
  }

  Future<void> createStateView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS state_view''');

    await db.execute('''
    CREATE VIEW IF NOT EXISTS state_view AS
    WITH state_log_filtered AS (
            SELECT *
              FROM state_log
            WHERE buildStatus ='pending'
        ),
        add_priority AS (
            SELECT *,
              CASE 
                WHEN stateName = 'evalStatus' THEN 1
                WHEN stateName = 'otherStatus' THEN 2
                ELSE 100 
              END AS priority
            FROM state_log_filtered
        )
        SELECT *
          FROM add_priority
        ORDER BY priority, stateChangeTimestamp
    ''');
  }

  // Future<void> createStateQueueView(Database db) async {
  //   await db.execute('''DROP VIEW IF EXISTS state_queue_view''');
  //   await db.execute('''
  //   CREATE VIEW IF NOT EXISTS state_queue_view AS
  //   WITH pending_state AS (
  //       SELECT *,
  //             MAX(CASE WHEN buildStatus = 'building' THEN 1 ELSE 0 END) OVER (PARTITION BY stateName) AS has_building
  //         FROM state_view
  //   )
  //   SELECT stateLogID,
  //         stateName,
  //         stateValue,
  //         buildStatus,
  //         stateChangeTimestamp,
  //         priority
  //     FROM (
  //             SELECT *,
  //                     MIN(stateChangeTimestamp) OVER (PARTITION BY stateName) AS minStateChangeTimestamp
  //               FROM pending_state
  //               WHERE buildStatus = 'pending' AND
  //                     has_building = 0
  //         )
  //   WHERE stateChangeTimestamp = minStateChangeTimestamp
  //     ''');
  // }

  // Future<void> createXxxView(Database db) async {
  //   await db.execute('''DROP VIEW IF EXISTS queue_proportion_view''');
  //   await db.execute('''
  //   CREATE VIEW IF NOT EXISTS queue_10_current_level_view AS

  //   ''');
  // }
}
