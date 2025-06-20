// file: problem_serivce.dart

import 'package:sqflite/sqflite.dart';
import '../../daos/process_log_dao.dart';
// import 'package:automath/services/database_provider.dart';
import 'package:automath/services/schema/database_creation_service.dart';

class DatabaseTableService {
  DatabaseTableService._internal();

  static final DatabaseTableService _instance =
      DatabaseTableService._internal();

  factory DatabaseTableService() => _instance;

  Database? _database;

  Future<void> onCreate(Database db, int version) {
    return _onCreate(db, version);
  }

  Future<void> _onCreate(Database db, int version) async {
    await createProcessingMetadataTable(db);
    await createStepLogTable(db);
    await createStepStatsTable(db);
    await createProblemLogTable(db);
    await createProblemStatsTable(db);
    await createSetLogTable(db);
    await createSessionLogTable(db);
    await createDateLogTable(db);
    await createOverallLevelLogTable(db);
    await createParamLevelLogTable(db);
    await createClaimedProgressLevelLogTable(db);
    await createMathFeelingLevelLogTable(db);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      'app_database.db',
      version: 1,
      onCreate: DatabaseCreationService().onCreate,
    );

    return _database!;
  }

  Future<void> createStepLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS step_log (
        stepLogID  INTEGER PRIMARY KEY AUTOINCREMENT,
        probLogID TEXT NOT NULL,
        queueName TEXT NOT NULL,
        priority INT NOT NULL,
        interventionLevel INT NOT NULL,
        overallLevel INT NOT NULL,
        gradeLevel INTEGER NOT NULL,
        subLevelScore INTEGER NOT NULL,
        paramLevelScore INTEGER NOT NULL,
        probID TEXT NOT NULL,
        probText TEXT NOT NULL,
        paramType TEXT NOT NULL,
        numSteps INTEGER NOT NULL,
        stepNo INTEGER NOT NULL,
        stepCalc TEXT NOT NULL,
        attempt INTEGER NOT NULL,
        evalStatus TEXT NOT NULL,
        timeTaken INTEGER NOT NULL,
        fluencyStepTimeGap REAL NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  // Need to convert isProblemCorrect from boolean to int 0 1
  Future<void> createProblemLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS problem_log (
        setID INT NOT NULL,
        probLogID TEXT PRIMARY KEY,
        probID TEXT NOT NULL,
        queueName TEXT NOT NULL,
        priority INT NOT NULL,
        interventionLevel INT NOT NULL,
        overallLevel INT NOT NULL,
        gradeLevel INTEGER NOT NULL,
        subLevelScore INTEGER NOT NULL,
        paramLevelScore INTEGER NOT NULL,
        probText TEXT NOT NULL,
        paramType TEXT NOT NULL,
        numSteps INTEGER NOT NULL,
        numCorrectStepsFirstTry INTEGER NOT NULL,
        numIncorrectStepsFirstTry INTEGER NOT NULL,
        isProblemCorrect INTEGER NOT NULL,
        isProblemTimely INTEGER NOT NULL,
        isProblemFluent INTEGER NOT NULL,
        propStepsCorrect REAL NOT NULL,
        propStepsIncorrect REAL NOT NULL,
        timeTaken INTEGER NOT NULL,
        fluencyProblemTimeGap REAL NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createStepStatsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS step_stats (
        stepStatsID INTEGER PRIMARY KEY AUTOINCREMENT,
        stepCalc TEXT NOT NULL UNIQUE,
        correctAttempts INT NOT NULL,
        incorrectAttempts INT NOT NULL,
        totAttempts INT NOT NULL,
        propIncorrect REAL NOT NULL,
        propCorrect REAL NOT NULL,
        totTime INT NOT NULL,
        timePerStep REAL NOT NULL,
        avgFluencyStepTimeGap REAL NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createProcessingMetadataTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS process_log (
        processName TEXT PRIMARY KEY,
        lastTimeStamp INT NOT NULL
      );
    ''');
  }

  Future<void> createProblemStatsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS problem_stats (
        probText TEXT PRIMARY KEY,
        correctSolves INT NOT NULL,
        incorrectSolves INT NOT NULL,
        totAttempts INT NOT NULL,
        propIncorrect REAL NOT NULL,
	      propCorrect REAL NOT NULL,
	      totSolveTime INT NOT NULL,
        avgSolveTime REAL NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createSetLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS set_log (
        setLogID INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL DEFAULT (date('now', 'localtime')), -- Stores only the date (YYYY-MM-DD)
        sessionID INT NOT NULL,
        setID INT NOT NULL,
        numCorrect INT NOT NULL,
        numIncorrect INT NOT NULL,
        numProblems INT NOT NULL,
        propCorrect REAL NOT NULL,
        propIncorrect REAL NOT NULL,
        timeTaken INT NOT NULL,
        timePerProblem REAL NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
        UNIQUE(date, sessionID, setID) -- Ensures only one entry per session/set/date
      );
    ''');
  }

  Future<void> createSessionLogTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS session_log (
      sessionLogID INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL DEFAULT (date('now', 'localtime')),
      sessionID INT NOT NULL,
      numSets INT NOT NULL,
      numCorrect INT NOT NULL,
      numIncorrect INT NOT NULL,
      numProblems INT NOT NULL,
      propCorrect REAL NOT NULL,
      propIncorrect REAL NOT NULL,
      timeTaken INT NOT NULL,
      timePerProblem REAL NOT NULL,
      timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      UNIQUE(date, sessionID) -- Ensures only one entry per date/session
      );
    ''');
  }

  Future<void> createDateLogTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS date_log (
      date TEXT PRIMARY KEY,
      numSessions INT NOT NULL,
      numCorrect INT NOT NULL,
      numIncorrect INT NOT NULL,
      numProblems INT NOT NULL,
      propCorrect REAL NOT NULL,
      propIncorrect REAL NOT NULL,
      timeTaken INT NOT NULL,
      timePerProblem REAL NOT NULL,
      timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createOverallLevelLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE overall_level_log (
        overallLevelLogID  INTEGER PRIMARY KEY AUTOINCREMENT,
        currentOverallLevel INTEGER NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createParamLevelLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE param_level_log (
        paramLevelLogID  INTEGER PRIMARY KEY AUTOINCREMENT,
        currentParamLevel INTEGER NOT NULL,
        timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
      );
    ''');
  }

  Future<void> createClaimedProgressLevelLogTable(Database db) async {
    await db.execute('''
    CREATE TABLE claimed_progress_level_log (
      claimedProgressLevelLogID INTEGER PRIMARY KEY AUTOINCREMENT,
      claimedProgressLevel INTEGER NOT NULL CHECK (claimedProgressLevel IN (-1, 0, 1)),
      timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
    );
  ''');
  }

  Future<void> createMathFeelingLevelLogTable(Database db) async {
    await db.execute('''
    CREATE TABLE math_feeling_level_log (
      mathFeelingLevelLogID INTEGER PRIMARY KEY AUTOINCREMENT,
      mathFeelingLevel INTEGER NOT NULL CHECK (mathFeelingLevel IN (-1, 0, 1)),
      timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
    );
  ''');
  }

  Future<void> initializeProcessLogMetadata() async {
    await ProcessLogDao().upsertProcessLog('summarizeStepLogToStats');
    await ProcessLogDao().upsertProcessLog('summarizeStepLogToProblemLog');
    await ProcessLogDao().upsertProcessLog('summarizeProblemLogToProblemStats');
    await ProcessLogDao().upsertProcessLog('summarizeProblemLogToSetLog');
    await ProcessLogDao().upsertProcessLog('summarizeSetLogToSessionLog');
    await ProcessLogDao().upsertProcessLog('summarizeSessionLogToDateLog');
  }
}
