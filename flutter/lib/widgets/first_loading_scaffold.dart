// FILE: first_loading_scaffold.dart

import 'package:flutter/material.dart';
import 'package:automath/services/schema/database_table_service.dart';
import 'package:automath/services/schema/progression_view_service.dart';
import 'package:automath/services/schema/ui_preflow_view_service.dart';
import 'package:automath/daos/next_route_dao.dart';
import 'package:automath/services/schema/problem_queue_view_service.dart';
import 'package:automath/services/state/database_table_service.dart'
    as stateDbTableService;
import 'package:automath/services/state/database_view_service.dart' as stateDbViewService;
import 'package:automath/managers/state_manager.dart';

class FirstLoadingScaffold extends StatefulWidget {
  const FirstLoadingScaffold({super.key});

  @override
  State<FirstLoadingScaffold> createState() => _FirstLoadingScaffoldState();
}

class _FirstLoadingScaffoldState extends State<FirstLoadingScaffold> {
  late final Future<String?> _initFuture;
  bool _navigated = false;

  static const _minimumSplashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<String?> _initializeApp() async {
    final stopwatch = Stopwatch()..start();

    final schemaDb = await ProgressionViewService().database;
    await DatabaseTableService().initializeProcessLogMetadata();
    await ProgressionViewService().createOrReplaceViews(schemaDb);
    await ProblemQueueViewService().createOrReplaceViews(schemaDb);
    await UiPreflowViewService().createOrReplaceViews(schemaDb);

    final stateDb = await stateDbTableService.DatabaseTableService().database;
    await stateDbViewService.DatabaseViewService().createOrReplaceViews(stateDb);

    await StateManager().startEvaluatorLoop();

    print("LOAD PYTHON FILES");

    final elapsed = stopwatch.elapsed;
    final waitTime = _minimumSplashDuration - elapsed;
    if (!waitTime.isNegative) {
      await Future.delayed(waitTime);
    }

    final nextRoute = await NextRouteDao().getNextRoute();
    return nextRoute.nextRoute;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'MathStairs',
                style: TextStyle(color: Colors.white, fontSize: 64),
              ),
            ),
          );
        }

        if (!_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, snapshot.data!);
          });
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'MathStairs',
              style: TextStyle(color: Colors.white, fontSize: 64),
            ),
          ),
        );
      },
    );
  }
}
