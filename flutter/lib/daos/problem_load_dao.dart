// file: problem_load_dao.dart

import 'package:automath/models/problem_data.dart';
import 'package:automath/services/schema/database_table_service.dart';

class ProblemLoadDao {
  // Singleton instance
  static final ProblemLoadDao _instance = ProblemLoadDao._internal();
  factory ProblemLoadDao() => _instance;
  ProblemLoadDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  /// Returns 10 problems from DB at 3rd grade level
  Future<List<ProblemData>> loadTenProblemsStatically() async {
    final db = await _dbService.database; // Get database instance

    final qryProblemsDb = await db.rawQuery('''
    SELECT *
    FROM problem_final
    WHERE overallLevel = 8
    LIMIT 10
      ''');

    // Call factory constructor to create a list of DataProblem objects
    final problemSet =
        qryProblemsDb.map((row) => ProblemData.fromMap(row)).toList();

    return problemSet;
  }

  /// Fetches a single problem by probText, paramType, and optional paramNum.
  Future<ProblemData> getProblemFromProbText(
      {required probText, required paramType, String paramNum = "01"}) async {
    final db = await _dbService.database;

    final qryProblem = await db.rawQuery('''
      SELECT * 
      FROM problem_final
      WHERE probText = ? AND 
            paramType = ? AND 
            paramNum = ?;
    ''', [probText, paramType, paramNum]);

    ProblemData problem = ProblemData.fromMap(qryProblem.first);
    return problem;
  }

  Future<ProblemData> getNextProblemFromQueueAll() async {
    final db = await _dbService.database;

    final map = await db.rawQuery('''
    SELECT *
      FROM queue_all_view
    LIMIT 1
    ''');

    if (map.isNotEmpty) {
      return ProblemData.fromMap(map.first);
    } else {
      throw Exception("No problems available in queue_all_view.");
    }
  }
}
