// FILE: problem_manager.dart

import 'package:automath/models/problem_data.dart';
import 'package:automath/daos/problem_load_dao.dart';

class ProblemManager {
  static final ProblemManager _instance = ProblemManager._internal();
  factory ProblemManager() => _instance;
  ProblemManager._internal();

  late ProblemData _currentProblem;

  bool isProblemQuickSolve() {
    return _currentProblem.quickSolveFlag == 1;
  }

  ProblemData get currentProblem => _currentProblem;

  Future<void> loadNextProblemFromQueueAll() async {
    _currentProblem = await ProblemLoadDao().getNextProblemFromQueueAll();
    print("currentProblem loaded");
  }
}
