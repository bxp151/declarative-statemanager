// file: database_view_serivce.dart

import 'package:sqflite/sqflite.dart';
import 'package:automath/services/schema/database_creation_service.dart';

class ProgressionViewService {
  ProgressionViewService._internal();

  static final ProgressionViewService _instance =
      ProgressionViewService._internal();

  factory ProgressionViewService() => _instance;

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
    await createProblemLogCombinedView(db);
    await createLevelPerformanceView(db);
    await createProblemPerformanceCombinedView(db);
    await createProblemPerformanceProgressView(db);
    await createProblemAndAttemptCombinedView(db);
    await createProblemAndAttemptCurrentLevelView(db);
    await createPrevCurrNextOverallLevelView(db);
    await createPrevCurrNextParamLevelView(db);
    await createDecisionOverallLevelView(db);
    await createDecisionParamLevelView(db);
    await createDecisionQuickSolveRateView(db);
  }

  /// Creates a view summarizing problem performance by level across recent and all attempts.
  Future<void> createLevelPerformanceView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS level_performance_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS level_performance_view AS
    WITH problem_stats AS (
        SELECT 
            overallLevel,
            gradeLevel,
            subLevelScore,
            ROW_NUMBER() OVER (PARTITION BY overallLevel ORDER BY timestamp DESC) AS rn,
            isProblemCorrect,
            isProblemTimely,
            isProblemFluent
        FROM problem_log_combined_view
    )
    SELECT 
        overallLevel,
        gradeLevel,
        subLevelScore,
        COUNT(*) AS numberProblems,
        
        -- Last 1
        AVG(CASE WHEN rn <= 1 THEN isProblemCorrect ELSE NULL END) AS last1PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 1 THEN isProblemTimely ELSE NULL END) AS last1PropIsProblemTimely,
        AVG(CASE WHEN rn <= 1 THEN isProblemFluent ELSE NULL END) AS last1PropIsProblemFluent,
        
        -- Last 10
        AVG(CASE WHEN rn <= 10 THEN isProblemCorrect ELSE NULL END) AS last10PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 10 THEN isProblemTimely ELSE NULL END) AS last10PropIsProblemTimely,
        AVG(CASE WHEN rn <= 10 THEN isProblemFluent ELSE NULL END) AS last10PropIsProblemFluent,
        
        -- Last 15
        AVG(CASE WHEN rn <= 15 THEN isProblemCorrect ELSE NULL END) AS last15PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 15 THEN isProblemTimely ELSE NULL END) AS last15PropIsProblemTimely,
        AVG(CASE WHEN rn <= 15 THEN isProblemFluent ELSE NULL END) AS last15PropIsProblemFluent,
        
        -- Last 20
        AVG(CASE WHEN rn <= 20 THEN isProblemCorrect ELSE NULL END) AS last20PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 20 THEN isProblemTimely ELSE NULL END) AS last20PropIsProblemTimely,
        AVG(CASE WHEN rn <= 20 THEN isProblemFluent ELSE NULL END) AS last20PropIsProblemFluent,
        
        -- Last 25
        AVG(CASE WHEN rn <= 25 THEN isProblemCorrect ELSE NULL END) AS last25PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 25 THEN isProblemTimely ELSE NULL END) AS last25PropIsProblemTimely,
        AVG(CASE WHEN rn <= 25 THEN isProblemFluent ELSE NULL END) AS last25PropIsProblemFluent,
        
        -- Last 30
        AVG(CASE WHEN rn <= 30 THEN isProblemCorrect ELSE NULL END) AS last30PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 30 THEN isProblemTimely ELSE NULL END) AS last30PropIsProblemTimely,
        AVG(CASE WHEN rn <= 30 THEN isProblemFluent ELSE NULL END) AS last30PropIsProblemFluent,
        
        -- Last 50
        AVG(CASE WHEN rn <= 50 THEN isProblemCorrect ELSE NULL END) AS last50PropIsProblemCorrect,
        AVG(CASE WHEN rn <= 50 THEN isProblemTimely ELSE NULL END) AS last50PropIsProblemTimely,
        AVG(CASE WHEN rn <= 50 THEN isProblemFluent ELSE NULL END) AS last50PropIsProblemFluent,
        
        -- All
        AVG(isProblemCorrect) AS allPropIsProblemCorrect,
        AVG(isProblemTimely) AS allPropIsProblemTimely,
        AVG(isProblemFluent) AS allPropIsProblemFluent

    FROM problem_stats
    GROUP BY overallLevel, gradeLevel, subLevelScore
    ''');
  }

  Future<void> createProblemAndAttemptCombinedView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS problem_and_attempt_combined_view''');

    await db.execute('''
    CREATE VIEW IF NOT EXISTS problem_and_attempt_combined_view AS
    SELECT f.instanceID,
          f.overallLevel,
          f.paramLevelScore,
          f.paramType,
          a.lastServedTimestamp,
          a.numTimesCompleted
      FROM problem_final AS f
          JOIN
          problem_attempt_log AS a ON f.instanceID = a.instanceID
    ''');
  }

  Future<void> createProblemAndAttemptCurrentLevelView(Database db) async {
    await db.execute(
        '''DROP VIEW IF EXISTS problem_and_attempt_current_level_view''');

    await db.execute('''
    CREATE VIEW IF NOT EXISTS problem_and_attempt_current_level_view AS
    SELECT *
    from problem_and_attempt_combined_view
    WHERE overallLevel IN (
            SELECT currentOverallLevel
            FROM overall_level_log
            WHERE currentOverallLevel IS NOT NULL
            ORDER BY timestamp DESC
            LIMIT 1
          )
    ''');
  }

  /// Combines step_log and problem_log stats to provided a unified view of problem performance
  ///   - step_log: Collects single-step and harvests the steps from multi-step problems
  ///   - problem_log: Collects multi-step problems
  Future<void> createProblemLogCombinedView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS problem_log_combined_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS problem_log_combined_view AS
    WITH step_log_to_problem_log AS (
                    SELECT 
                        'step_log' AS source,
                        s.probLogID as probLogID,
                        s.stepLogID as stepLogID,
                        f.instanceID AS probID,
                        f.paramType,
                        s.interventionLevel,
                        f.overallLevel,
                        f.gradeLevel,
                        f.subLevelScore,
                        f.paramLevelScore,
                        s.stepCalc AS probText,
                        f.numSteps,
                        CASE WHEN s.evalStatus = 'step_correct' THEN 1 ELSE 0 END AS isProblemCorrect,
                        CASE WHEN s.fluencyStepTimeGap > 0 THEN 1 ELSE 0 END AS isProblemTimely,
                        CASE WHEN s.evalStatus = 'step_correct' AND s.fluencyStepTimeGap > 0 THEN 1 ELSE 0 END AS isProblemFluent,
                        s.timeTaken,
                        s.fluencyStepTimeGap AS fluencyProblemTimeGap,
                        s.timestamp
                    FROM step_log AS s
                    JOIN problem_final AS f ON s.stepCalc = f.probText
                    WHERE f.paramType = 'full'
                      AND f.numSteps = 1
                      AND s.attempt = 1
                ),
                curated_problem_log AS (
                    SELECT 
                        'problem_log' AS source,
                        probLogID as probLogID,
                        NULL as steplogID,
                        probID,
                        paramType,
                        interventionLevel,
                        overallLevel,
                        gradeLevel,
                        subLevelScore,
                        paramLevelScore,
                        probText,
                        numSteps,
                        isProblemCorrect,
                        isProblemTimely,
                        isProblemFluent,
                        timeTaken,
                        fluencyProblemTimeGap, 
                        timestamp
                    FROM problem_log
                    WHERE numSteps > 1
                )
                SELECT * FROM step_log_to_problem_log
                UNION ALL
                SELECT * FROM curated_problem_log
                ORDER BY timestamp ASC
    ''');
  }

  Future<void> createProblemPerformanceCombinedView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS problem_performance_combined_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS problem_performance_combined_view AS
    WITH problem_log_stats AS (
            SELECT 
                probID,
                probText,
                interventionLevel,
                overallLevel,
                gradeLevel,
                subLevelScore,
                numSteps,
                ROW_NUMBER() OVER (PARTITION BY probID, interventionLevel ORDER BY probID, interventionLevel, timestamp DESC) AS rn,
                isProblemCorrect,
                isProblemTimely,
                isProblemFluent
            FROM problem_log_combined_view
        )
        SELECT 
            s.probID,
            s.probText,
            a.lastServedTimestamp,
            s.interventionLevel,
            s.overallLevel,
            s.gradeLevel,
            s.subLevelScore,
            s.numSteps,
            COUNT(*) AS numberProblems,

            -- Last 1
            AVG(CASE WHEN rn <= 1 THEN isProblemCorrect ELSE NULL END) AS last1PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 1 THEN isProblemTimely ELSE NULL END) AS last1PropIsProblemTimely,
            AVG(CASE WHEN rn <= 1 THEN isProblemFluent ELSE NULL END) AS last1PropIsProblemFluent,

            -- Last 2
            AVG(CASE WHEN rn <= 2 THEN isProblemCorrect ELSE NULL END) AS last2PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 2 THEN isProblemTimely ELSE NULL END) AS last2PropIsProblemTimely,
            AVG(CASE WHEN rn <= 2 THEN isProblemFluent ELSE NULL END) AS last2PropIsProblemFluent,

            -- Last 3
            AVG(CASE WHEN rn <= 3 THEN isProblemCorrect ELSE NULL END) AS last3PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 3 THEN isProblemTimely ELSE NULL END) AS last3PropIsProblemTimely,
            AVG(CASE WHEN rn <= 3 THEN isProblemFluent ELSE NULL END) AS last3PropIsProblemFluent,

            -- Last 4
            AVG(CASE WHEN rn <= 4 THEN isProblemCorrect ELSE NULL END) AS last4PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 4 THEN isProblemTimely ELSE NULL END) AS last4PropIsProblemTimely,
            AVG(CASE WHEN rn <= 4 THEN isProblemFluent ELSE NULL END) AS last4PropIsProblemFluent,

            -- Last 5
            AVG(CASE WHEN rn <= 5 THEN isProblemCorrect ELSE NULL END) AS last5PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 5 THEN isProblemTimely ELSE NULL END) AS last5PropIsProblemTimely,
            AVG(CASE WHEN rn <= 5 THEN isProblemFluent ELSE NULL END) AS last5PropIsProblemFluent,

            -- Last 6
            AVG(CASE WHEN rn <= 6 THEN isProblemCorrect ELSE NULL END) AS last6PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 6 THEN isProblemTimely ELSE NULL END) AS last6PropIsProblemTimely,
            AVG(CASE WHEN rn <= 6 THEN isProblemFluent ELSE NULL END) AS last6PropIsProblemFluent,

            -- Last 7
            AVG(CASE WHEN rn <= 7 THEN isProblemCorrect ELSE NULL END) AS last7PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 7 THEN isProblemTimely ELSE NULL END) AS last7PropIsProblemTimely,
            AVG(CASE WHEN rn <= 7 THEN isProblemFluent ELSE NULL END) AS last7PropIsProblemFluent,

            -- Last 8
            AVG(CASE WHEN rn <= 8 THEN isProblemCorrect ELSE NULL END) AS last8PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 8 THEN isProblemTimely ELSE NULL END) AS last8PropIsProblemTimely,
            AVG(CASE WHEN rn <= 8 THEN isProblemFluent ELSE NULL END) AS last8PropIsProblemFluent,

            -- Last 9
            AVG(CASE WHEN rn <= 9 THEN isProblemCorrect ELSE NULL END) AS last9PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 9 THEN isProblemTimely ELSE NULL END) AS last9PropIsProblemTimely,
            AVG(CASE WHEN rn <= 9 THEN isProblemFluent ELSE NULL END) AS last9PropIsProblemFluent,

            -- Last 10
            AVG(CASE WHEN rn <= 10 THEN isProblemCorrect ELSE NULL END) AS last10PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 10 THEN isProblemTimely ELSE NULL END) AS last10PropIsProblemTimely,
            AVG(CASE WHEN rn <= 10 THEN isProblemFluent ELSE NULL END) AS last10PropIsProblemFluent,

            -- Last 20
            AVG(CASE WHEN rn <= 20 THEN isProblemCorrect ELSE NULL END) AS last20PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 20 THEN isProblemTimely ELSE NULL END) AS last20PropIsProblemTimely,
            AVG(CASE WHEN rn <= 20 THEN isProblemFluent ELSE NULL END) AS last20PropIsProblemFluent,

            -- Last 50
            AVG(CASE WHEN rn <= 50 THEN isProblemCorrect ELSE NULL END) AS last50PropIsProblemCorrect,
            AVG(CASE WHEN rn <= 50 THEN isProblemTimely ELSE NULL END) AS last50PropIsProblemTimely,
            AVG(CASE WHEN rn <= 50 THEN isProblemFluent ELSE NULL END) AS last50PropIsProblemFluent

        FROM problem_log_stats AS s
        JOIN problem_attempt_log AS a ON s.probID = a.instanceID
        GROUP BY s.interventionLevel, s.probID
    ''');
  }

  /// Same as createProblemPerformanceCombinedView filtered by
  /// interventionLevel = 0 | This is the standard problem queue
  Future<void> createProblemPerformanceProgressView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS problem_performance_progress_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS problem_performance_progress_view AS
    SELECT *
      FROM problem_performance_combined_view
    WHERE interventionLevel = 0;
    ''');
  }

  Future<void> createPrevCurrNextOverallLevelView(Database db) async {
    await db
        .execute('''DROP VIEW IF EXISTS prev_curr_next_overall_level_view''');

    await db.execute('''
    CREATE VIEW IF NOT EXISTS prev_curr_next_overall_level_view AS
    WITH level_bounds AS (
      SELECT 
        MIN(overallLevel) AS minLevel,
        MAX(overallLevel) AS maxLevel
      FROM problem_final
    )
    SELECT 
      pf.overallLevel AS currentOverallLevel,
      CASE 
        WHEN pf.overallLevel = lb.minLevel THEN pf.overallLevel
        ELSE pf.overallLevel - 1
      END AS previousOverallLevel,
      CASE 
        WHEN pf.overallLevel = lb.maxLevel THEN pf.overallLevel
        ELSE pf.overallLevel + 1
      END AS nextOverallLevel
    FROM (
      SELECT DISTINCT overallLevel
      FROM problem_final
      WHERE overallLevel = (
        SELECT currentOverallLevel
          FROM overall_level_log
        ORDER BY timestamp DESC
        LIMIT 1
    )
    ) pf
    CROSS JOIN level_bounds lb
    ORDER BY pf.overallLevel
    ''');
  }

  Future<void> createPrevCurrNextParamLevelView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS prev_curr_next_param_level_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS prev_curr_next_param_level_view AS
    WITH 
    level_bounds AS (
      SELECT 
        MIN(paramLevelScore) AS minLevel,
        MAX(paramLevelScore) AS maxLevel
      FROM problem_final
    ),
    current_level AS (
      SELECT currentParamLevel AS paramLevelScore
      FROM param_level_log
      ORDER BY timestamp DESC
      LIMIT 1
    )
    SELECT 
      cl.paramLevelScore AS currentParamLevel,
      CASE 
        WHEN cl.paramLevelScore = lb.minLevel THEN cl.paramLevelScore
        ELSE cl.paramLevelScore - 1
      END AS previousParamLevel,
      CASE 
        WHEN cl.paramLevelScore = lb.maxLevel THEN cl.paramLevelScore
        ELSE cl.paramLevelScore + 1
      END AS nextParamLevel
    FROM current_level cl
    CROSS JOIN level_bounds lb
    ''');
  }

  Future<void> createDecisionOverallLevelView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS decision_overall_level_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS decision_overall_level_view AS
    WITH overallLevels AS (
        SELECT previousOverallLevel,
              currentOverallLevel,
              nextOverallLevel
          FROM prev_curr_next_overall_level_view
    ),
    decision_overall_level AS (
        SELECT 'overallLevel' AS levelType,
              o.currentOverallLevel AS currentLevel,
              CASE WHEN last10PropIsProblemCorrect <= 0.4 AND 
                        numberProblems >= 10 THEN o.previousOverallLevel WHEN last50PropIsProblemFluent >= 0.85 AND 
                                                                              numberProblems >= 50 THEN o.nextOverallLevel ELSE o.currentOverallLevel END AS newLevel
          FROM level_performance_view AS l
              JOIN
              overallLevels AS o ON o.currentOverallLevel = l.overallLevel
    )
    SELECT *
      FROM decision_overall_level
    ''');
  }

  Future<void> createDecisionParamLevelView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS decision_param_level_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS decision_param_level_view AS
    WITH overallLevels AS (
                SELECT previousOverallLevel, currentOverallLevel, nextOverallLevel
                  FROM prev_curr_next_overall_level_view
            ),
            paramLevels AS (
                SELECT previousParamLevel, currentParamLevel, nextParamLevel
                  FROM prev_curr_next_param_level_view
            ),
            decision_param_level AS (
                SELECT 
                    'paramLevel' AS levelType,
                    pl.currentParamLevel AS currentLevel,
                      CASE                           
                          WHEN last10PropIsProblemCorrect >= 0.8 AND 
                              numberProblems >= 10 AND 
                              pl.currentParamLevel = 0 THEN pl.nextParamLevel
                              
                          WHEN last15PropIsProblemCorrect >= 0.8 AND 
                              numberProblems >= 15 AND 
                              pl.currentParamLevel = 1 THEN pl.nextParamLevel
                              
                          WHEN last20PropIsProblemCorrect >= 0.8 AND 
                              numberProblems >= 20 AND 
                              pl.currentParamLevel = 2 THEN pl.nextParamLevel
                              
                          WHEN last25PropIsProblemCorrect >= 0.8 AND 
                              numberProblems >= 25 AND 
                              pl.currentParamLevel = 3 THEN pl.nextParamLevel
                              
                          WHEN last30PropIsProblemCorrect >= 0.8 AND 
                              numberProblems >= 30 AND 
                              pl.currentParamLevel = 4 THEN pl.nextParamLevel
                          
                          ELSE pl.currentParamLevel
                      END AS newLevel

                  FROM level_performance_view as l
                  JOIN overallLevels as o on o.currentOverallLevel = l.overallLevel
                  CROSS JOIN paramLevels pl
            )
            SELECT *
              FROM decision_param_level
    ''');
  }

  Future<void> createDecisionQuickSolveRateView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS decision_quick_solve_rate_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS decision_quick_solve_rate_view AS
    WITH current_level AS (
        SELECT currentOverallLevel
        FROM overall_level_log
        ORDER BY timestamp DESC
        LIMIT 1
    ),
    fallback_row AS (
        SELECT 0 AS numberProblems, 0.0 AS Last10PropIsProblemCorrect, 0.0 AS Last20PropIsProblemCorrect, 0.0 AS Last30PropIsProblemCorrect
    ),
    level_performance AS (
        SELECT
            COALESCE(lp.numberProblems, f.numberProblems) AS numberProblems,
            COALESCE(lp.Last10PropIsProblemCorrect, f.Last10PropIsProblemCorrect) AS Last10PropIsProblemCorrect,
            COALESCE(lp.Last20PropIsProblemCorrect, f.Last20PropIsProblemCorrect) AS Last20PropIsProblemCorrect,
            COALESCE(lp.Last30PropIsProblemCorrect, f.Last30PropIsProblemCorrect) AS Last30PropIsProblemCorrect
        FROM fallback_row f
        LEFT JOIN level_performance_view lp
          ON EXISTS (
              SELECT 1
              FROM current_level cl
              WHERE cl.currentOverallLevel = lp.overallLevel
          )
    )
    SELECT
        CASE 
            WHEN numberProblems >= 30 AND Last30PropIsProblemCorrect  >= 0.8 THEN 0.3
            WHEN numberProblems >= 20 AND Last20PropIsProblemCorrect  >= 0.8 THEN 0.2
            WHEN numberProblems >= 10 AND Last10PropIsProblemCorrect  >= 0.8 THEN 0.1
            ELSE 0.0
        END AS quickSolveRate
    FROM level_performance;
    ''');
  }

  // Future<void> createXxxView(Database db) async {
  //   await db.execute('''DROP VIEW IF EXISTS queue_proportion_view''');
  //   await db.execute('''
  //   CREATE VIEW IF NOT EXISTS queue_10_current_level_view AS

  //   ''');
  // }
}
