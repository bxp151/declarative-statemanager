import 'package:sqflite/sqflite.dart';
import 'package:demo/services/database_creation_service.dart';

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
    await createStateLogTable(db);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: DatabaseCreationService().onCreate,
    );

    return _database!;
  }

  Future<void> createStateLogTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS state_log (
      stateLogID INTEGER PRIMARY KEY AUTOINCREMENT,
      originWidget TEXT NOT NULL,
      originMethod TEXT NOT NULL,
      stateName TEXT NOT NULL,
      stateValue TEXT NOT NULL,
      originTimestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
      dispatchTimestamp INTEGER,
      destinationTimestamp INTEGER,
      widgetRebuildResult TEXT  
    );
    ''');
  }
}
