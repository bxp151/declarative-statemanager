// file: problem_queue_serivce.dart

import 'package:sqflite/sqflite.dart';
import 'package:automath/services/schema/database_creation_service.dart';

class ProblemQueueViewService {
  ProblemQueueViewService._internal();

  static final ProblemQueueViewService _instance =
      ProblemQueueViewService._internal();

  factory ProblemQueueViewService() => _instance;

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
    await createQueueProportionView(db);
    await createQueue01InterventionView(db);
    await createQueue10FullView(db);
    await createQueue11AnswerView(db);
    await createQueue12CarryView(db);
    await createQueue13OperandView(db);
    await createQueue30StepReviewView(db);
    await createQueue40ProblemReviewView(db);
    await createQueueAllView(db);
  }

  /// Creates a view to serve 100 least-seen problems at the current overall level.

  Future<void> createQueue01InterventionView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_01_intervention_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_01_intervention_view AS
    WITH prob_log_last_row AS (
            SELECT *
              FROM problem_log_combined_view
            ORDER BY timestamp DESC,
                      source ASC
            LIMIT 1
        ),
        prob_log_id AS (
            SELECT probLogID
              FROM prob_log_last_row
            WHERE numSteps > 1
        ),
        incorrect_steps AS (
            SELECT *
              FROM problem_log_combined_view
            WHERE probLogID = (
                                  SELECT probLogID
                                    FROM prob_log_id
                              )
        AND 
                  stepLogID IS NOT NULL AND 
                  isProblemCorrect = 0
        ),
        queue_metadata AS (
            SELECT 'queue_01_intervention_view' AS queueName,
        -          1 AS interventionLevel,
                  *,
                  1 AS priority
              FROM problem_and_attempt_combined_view
            WHERE instanceID IN (
                      SELECT probID
                        FROM incorrect_steps
                  )
        )
        SELECT q.queueName,
              q.interventionLevel,
              q.priority,
              q.lastServedTimestamp,
              q.numTimesCompleted,
              0 AS quickSolveFlag,
              f.probID,
              f.overallLevel,
              f.gradeLevel,
              f.subLevelScore,
              f.paramLevelScore,
              f.probText,
              f.answer,
              f.stepHuman,
              f.stepMap,
              f.solvedGrid,
              f.instanceID,
              f.paramType,
              f.paramNum,
              f.numParameters,
              f.numSteps,
              f.paramGrid,
              f.stepsToParams
          FROM queue_metadata q
              JOIN
              problem_final f ON q.instanceID = f.instanceID
    ''');
  }

  Future<void> createQueue10FullView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_10_full_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_10_full_view AS
    WITH queue_metadata AS (
        SELECT 'queue_10_full_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_current_level_view
        WHERE paramType = 'full'
        ORDER BY lastServedTimestamp ASC,
                  numTimesCompleted ASC
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_10_full_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_10_full_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID;
    ''');
  }

  Future<void> createQueue11AnswerView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_11_answer_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_11_answer_view AS
    WITH queue_metadata AS (
        SELECT 'queue_11_answer_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_current_level_view
        WHERE paramType = 'answer'
        ORDER BY lastServedTimestamp ASC,
                  numTimesCompleted ASC
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_11_answer_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_11_answer_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID;
    ''');
  }

  Future<void> createQueue12CarryView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_12_carry_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_12_carry_view AS
    WITH queue_metadata AS (
        SELECT 'queue_12_carry_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_current_level_view
        WHERE paramType = 'carry'
        ORDER BY lastServedTimestamp ASC,
                  numTimesCompleted ASC
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_12_carry_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_12_carry_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID;
    ''');
  }

  Future<void> createQueue13OperandView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_13_operand_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_13_operand_view AS
    WITH queue_metadata AS (
        SELECT 'queue_13_operand_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_current_level_view
        WHERE paramType = 'operand' AND 
              paramLevelScore = (
                                    SELECT currentParamLevel
                                      FROM prev_curr_next_param_level_view
                                )
        ORDER BY lastServedTimestamp ASC,
                  numTimesCompleted ASC
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_13_operand_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_13_operand_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID;
    ''');
  }

  Future<void> createQueue30StepReviewView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_30_step_review_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_30_step_review_view AS
    WITH queue_metadata AS (
        SELECT 'queue_30_step_review_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_combined_view
        WHERE instanceID IN (
                  SELECT probID
                    FROM problem_performance_progress_view
                    WHERE Last1PropIsProblemFluent < 1 AND 
                          numSteps = 1
              )
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_30_step_review_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_30_step_review_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID;
    ''');
  }

  Future<void> createQueue40ProblemReviewView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_40_problem_review_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_40_problem_review_view AS
    WITH queue_metadata AS (
        SELECT 'queue_40_problem_review_view' AS queueName,
              0 AS interventionLevel,
              100 AS priority,
              *
          FROM problem_and_attempt_combined_view
        WHERE instanceID IN (
                  SELECT probID
                    FROM problem_performance_progress_view
                    WHERE Last1PropIsProblemFluent < 1 AND 
                          numSteps > 1
              )
        LIMIT (
                  SELECT numberProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_40_problem_review_view'
              )
    ),
    add_row_number_and_quick_solve_rate AS (
        SELECT ROW_NUMBER() OVER (ORDER BY (
                  SELECT NULL
              )
              ) AS rn,
              *
          FROM queue_metadata
              CROSS JOIN
              (
                  SELECT quickSolveEveryNProblems
                    FROM queue_proportion_view
                    WHERE queueName = 'queue_40_problem_review_view'
              )
    ),
    add_quick_solve_flag AS (
        SELECT queueName,
              interventionLevel,
              priority,
              instanceID,
              overallLevel,
              paramLevelScore,
              paramType,
              lastServedTimestamp,
              numTimesCompleted,
              CASE WHEN rn % quickSolveEveryNProblems = 0 THEN 1 ELSE 0 END AS quickSolveFlag
          FROM add_row_number_and_quick_solve_rate
    )
    SELECT aq.queueName,
          aq.interventionLevel,
          aq.priority,
          aq.lastServedTimestamp,
          aq.numTimesCompleted,
          aq.quickSolveFlag,
          f.*
      FROM add_quick_solve_flag aq
          JOIN
          problem_final f ON aq.instanceID = f.instanceID; 
    ''');
  }

  /// Creates a view that dynamically assigns problem queue proportions
  /// based on the current parameter level (`paramLevel`).
  ///
  /// The paramLevels are generated by the problem generator.
  /// Full & Answer: 0  |  Carry: 1  |  Operand: 2+
  ///
  /// - `queue_10_full_view`: always 40%
  /// - `queue_30_step_review_view`: always 20%
  /// - `queue_40_problem_review_view`: always 10%
  ///
  /// - `queue_11_answer_view`:
  ///     - 30% if paramLevel = 0
  ///     - 15% if paramLevel = 1
  ///     - 10% if paramLevel ≥ 2
  ///
  /// - `queue_12_carry_view`:
  ///     - 0% if paramLevel = 0
  ///     - 15% if paramLevel = 1
  ///     - 10% if paramLevel ≥ 2
  ///
  /// - `queue_13_operand_view`:
  ///     - 10% if paramLevel ≥ 2
  Future<void> createQueueProportionView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_proportion_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_proportion_view AS
    WITH current_param_level AS (
        SELECT currentParamLevel AS paramLevel
        FROM param_level_log
        ORDER BY timestamp DESC
        LIMIT 1
    ),
    quick_solve_rate AS (
        SELECT quickSolveRate 
        FROM decision_quick_solve_rate_view
    ),
    queue_names AS (
        SELECT name AS queueName
        FROM sqlite_master
        WHERE type = 'view' 
          AND name GLOB 'queue_[0-9]*'
    ),
    queue_names_param_levels AS (
        SELECT q.queueName,
              c.paramLevel,
              qsr.quickSolveRate
        FROM queue_names q
        CROSS JOIN current_param_level c
        CROSS JOIN quick_solve_rate qsr
    ),
    number_problems_case AS (
        SELECT queueName,
              paramLevel,
              quickSolveRate,
              CASE 
                  WHEN queueName = 'queue_10_full_view' THEN 40 
                  WHEN queueName = 'queue_11_answer_view' AND paramLevel = 0 THEN 30
                  WHEN queueName = 'queue_11_answer_view' AND paramLevel = 1 THEN 15
                  WHEN queueName = 'queue_11_answer_view' AND paramLevel >= 2 THEN 10               
                  WHEN queueName = 'queue_12_carry_view' AND paramLevel = 0 THEN 0 
                  WHEN queueName = 'queue_12_carry_view' AND paramLevel = 1 THEN 15
                  WHEN queueName = 'queue_12_carry_view' AND paramLevel >= 2 THEN 10
                  WHEN queueName = 'queue_13_operand_view' AND paramLevel >= 2 THEN 10 
                  WHEN queueName = 'queue_30_step_review_view' THEN 20
                  WHEN queueName = 'queue_40_problem_review_view' THEN 10           
                  ELSE 0 
              END AS numberProblems
        FROM queue_names_param_levels
        ORDER BY queueName
    )
    SELECT queueName,
          --paramLevel,
          --quickSolveRate,
          numberProblems,
          CASE 
              WHEN queueName = 'queue_10_full_view' THEN CEIL(numberProblems / (quickSolveRate * numberProblems))
              ELSE 0 
          END AS quickSolveEveryNProblems
    FROM number_problems_case;
    ''');
  }

  Future<void> createQueueAllView(Database db) async {
    await db.execute('''DROP VIEW IF EXISTS queue_all_view''');
    await db.execute('''
    CREATE VIEW IF NOT EXISTS queue_all_view AS
    WITH all_non_intervention_queues AS (
        SELECT *
          FROM queue_10_full_view
        UNION ALL
        SELECT *
          FROM queue_11_answer_view
        UNION ALL
        SELECT *
          FROM queue_12_carry_view
        UNION ALL
        SELECT *
          FROM queue_13_operand_view
        UNION ALL
        SELECT *
          FROM queue_30_step_review_view
        UNION ALL
        SELECT *
          FROM queue_40_problem_review_view
    ),
    all_non_intervention_queues_randomized AS (
        SELECT ROW_NUMBER() OVER (ORDER BY RANDOM() ) AS rn,
              *
          FROM all_non_intervention_queues
    ),
    all_non_intervention_queues_randomized_no_rn AS (
        SELECT queueName,
              interventionLevel,
              priority,
              lastServedTimestamp,
              numTimesCompleted,
              quickSolveFlag,
              probID,
              overallLevel,
              gradeLevel,
              subLevelScore,
              paramLevelScore,
              probText,
              answer,
              stepHuman,
              stepMap,
              solvedGrid,
              instanceID,
              paramType,
              paramNum,
              numParameters,
              numSteps,
              paramGrid,
              stepsToParams
          FROM all_non_intervention_queues_randomized
    ),
    all_intervention_queues AS (
        SELECT *
          FROM queue_01_intervention_view
    ),
    all_queues AS (
        SELECT *
          FROM all_non_intervention_queues_randomized_no_rn
        UNION ALL
        SELECT *
          FROM all_intervention_queues
    )
    SELECT *
      FROM all_queues
    ORDER BY priority
    ''');
  }

  // Future<void> createXxxView(Database db) async {
  //   await db.execute('''DROP VIEW IF EXISTS queue_proportion_view''');
  //   await db.execute('''
  //   CREATE VIEW IF NOT EXISTS queue_10_current_level_view AS

  //   ''');
  // }
}
