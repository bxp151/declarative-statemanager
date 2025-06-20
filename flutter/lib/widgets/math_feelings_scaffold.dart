// file:math_feelings_scaffold.dart
import 'package:flutter/material.dart';
import 'package:automath/daos/math_feeling_level_dao.dart';
import 'package:automath/models/math_feeling_level.dart';
import 'package:automath/daos/next_route_dao.dart';

class MathFeelingsScaffold extends StatefulWidget {
  const MathFeelingsScaffold({super.key});

  @override
  State<MathFeelingsScaffold> createState() => _MathFeelingScaffoldState();
}

class _MathFeelingScaffoldState extends State<MathFeelingsScaffold> {
  static const feelingEncoding = {
    'Happy': 1,
    'Ok': 0,
    'Sad': -1,
  };

  void _handleResponseTap(String stringResponse) async {
    final intResponse = feelingEncoding[stringResponse] ?? 0;
    await MathFeelingLevelDao().insertMathFeelingLevelLog(
        MathFeelingLevel(mathFeelingLevel: intResponse));

    //  Temporary, remove once you build second loading screen
    // await ProblemManager().loadNextProblemFromQueueAll();

    // Get next route
    final nextRoute = await NextRouteDao().getNextRoute();
    if (mounted) {
      Navigator.pushNamed(context, nextRoute.nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responses = [
      {'emoji': '😃', 'label': 'Happy'},
      {'emoji': '😐', 'label': 'Ok'},
      {'emoji': '😢', 'label': 'Sad'}
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'How are you feeling about math now?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: responses.map((response) {
                return GestureDetector(
                  onTap: () => _handleResponseTap(response['label']!),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            response['emoji']!,
                            style: const TextStyle(
                              fontSize: 64,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        response['label']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
