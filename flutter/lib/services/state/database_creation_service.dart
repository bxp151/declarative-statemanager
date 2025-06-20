// file: database_creation_serivce.dart

import 'package:sqflite/sqflite.dart';
import 'package:automath/services/state/database_table_service.dart';

class DatabaseCreationService {
  DatabaseCreationService._internal();

  static final DatabaseCreationService _instance =
      DatabaseCreationService._internal();

  factory DatabaseCreationService() => _instance;

  Future<void> onCreate(Database db, int version) {
    return _onCreate(db, version);
  }

  Future<void> _onCreate(Database db, int version) async {
    await DatabaseTableService().onCreate(db, version);
    // await ProgressionViewService().onCreate(db, version);
  }
}
