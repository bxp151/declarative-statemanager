// file: ui_preflow_view_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:automath/services/schema/database_creation_service.dart';

class UiPreflowViewService {
  UiPreflowViewService._internal();

  static final UiPreflowViewService _instance =
      UiPreflowViewService._internal();

  factory UiPreflowViewService() => _instance;

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
    await createUiPreflowSetupGradeLevelView(db);
    await createUiPreflowClaimedProgressView(db);
    await createUiPreflowMathFeelingsView(db);
    await createUiPreflowAllView(db);
  }

  /// Determines if the grade selection scaffold should be served
  Future<void> createUiPreflowSetupGradeLevelView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS ui_preflow_setup_grade_level_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS ui_preflow_setup_grade_level_view AS
    SELECT '/gradeselectionscreen' AS route,
          CASE WHEN COUNT( * ) = 0 THEN 1 
          ELSE 0 
          END AS serveRoute
        FROM overall_level_log
    ''');
  }

  /// Determines if the claimed progress scaffold should be served
  Future<void> createUiPreflowClaimedProgressView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS ui_preflow_claimed_progress_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS ui_preflow_claimed_progress_view AS
    WITH never_set AS (
          Select
          CASE 
              -- If no entries          
              WHEN COUNT(*) = 0 THEN 1
                          ELSE 0 
          END AS serveRoute
          FROM claimed_progress_level_log
    ),
    not_set_in_30 AS (
          Select 
            CASE 
              -- If last entry is over 30 days ago
              WHEN CAST(STRFTIME('%s','now') AS INTEGER) * 1000 - timestamp > 2592000000 THEN 1
              ELSE 0 
          END AS serveRoute
          FROM claimed_progress_level_log
    ), combined_set AS(
    select * from never_set
    UNION ALL
    select * from not_set_in_30
    )
    select '/claimedprogressscreen' AS screen,
        CASE 
            WHEN SUM(serveRoute) > 0 THEN 1 -- if one CTE is triggered
        ELSE 0
        END AS serveRoute
    from combined_set
    ''');
  }

  /// Determines if the math feelings scaffold should be served
  Future<void> createUiPreflowMathFeelingsView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS ui_preflow_math_feelings_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS ui_preflow_math_feelings_view AS
    WITH never_set AS (
        SELECT CASE
            WHEN COUNT( * ) = 0 THEN 1 
            ELSE 0 
            END AS serveRoute
          FROM math_feeling_level_log
    ),
    not_set_in_30 AS (
        SELECT CASE
            WHEN CAST (STRFTIME('%s', 'now') AS INTEGER) * 1000 - timestamp > 604800000 THEN 1 
            ELSE 0 
            END AS serveRoute
          FROM math_feeling_level_log
    ),
    combined_set AS (
        SELECT *
          FROM never_set
        UNION ALL
        SELECT *
          FROM not_set_in_30
    )
    SELECT '/mathfeelingsscreen' AS screen,
          CASE 
              WHEN SUM(serveRoute) > 0 THEN 1
              ELSE 0 
          END AS serveRoute
      FROM combined_set
 
    ''');
  }

  Future<void> createUiPreflowAllView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS ui_preflow_all_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS ui_preflow_all_view AS
    WITH combined_views AS (
            SELECT *,
                  1 AS priority
              FROM ui_preflow_setup_grade_level_view
            UNION ALL
            SELECT *,
                  2 AS priority
              FROM ui_preflow_claimed_progress_view
            UNION ALL
            SELECT *,
                  3 AS priority
              FROM ui_preflow_math_feelings_view
            UNION ALL
            SELECT '/problemloadingscaffold' AS route,
                  1 AS serveRoute,
                  4 AS priority
        )
        SELECT *
          FROM combined_views
        WHERE serveRoute = 1
        ORDER BY priority
    ''');
  }

  // Future<void> xXxView(Database db) async {
  //   await db.execute('''DROP VIEW IF EXISTS xx_view''');
  //   await db.execute('''
  //   CREATE VIEW IF NOT EXISTS xx_view AS
  //   ''');
  // }
}
