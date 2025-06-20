// FILE: progression_manager.dart

import 'package:automath/daos/overall_level_dao.dart';
import 'package:automath/daos/param_level_dao.dart';
import 'package:automath/models/overall_level.dart';
import 'package:automath/models/param_level.dart';

class ProgressionManager {
  static final ProgressionManager _instance = ProgressionManager._internal();
  factory ProgressionManager() => _instance;
  ProgressionManager._internal();

  Future<void> getAndSetLevels() async {
    // Get overall level from decision view and set it log
    OverallLevel decisionOverallLevel =
        await OverallLevelDao().getDecisionOverallLevel();
    await OverallLevelDao().insertOverallLevelLog(decisionOverallLevel);

    // Get parameter level from decision view and set it log
    ParamLevel decisionParamLevel =
        await ParamLevelDao().getDecisionParamLevel();
    await ParamLevelDao().insertParamLevelLog(decisionParamLevel);
  }
}
