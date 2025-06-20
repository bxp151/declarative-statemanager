// file: claimed_progress_scaffold.dart

import 'package:flutter/material.dart';
import 'package:automath/daos/claimed_progress_level_dao.dart';
import 'package:automath/models/claimed_progress_level.dart';
import 'package:automath/daos/next_route_dao.dart';

class ClaimedProgressScaffold extends StatefulWidget {
  const ClaimedProgressScaffold({super.key});

  @override
  State<ClaimedProgressScaffold> createState() =>
      _ClaimedProgressScaffoldState();
}

class _ClaimedProgressScaffoldState extends State<ClaimedProgressScaffold> {
  static const progressEncoding = {
    'Better': 1,
    'Same': 0,
    'Worse': -1,
  };

  void _handleResponseTap(String stringResponse) async {
    final intResponse = progressEncoding[stringResponse] ?? 0;
    await ClaimedProgressLevelDao().insertClaimedProgressLevelLog(
        ClaimedProgressLevel(claimedProgressLevel: intResponse));

    // Get next route
    final nextRoute = await NextRouteDao().getNextRoute();
    if (mounted) {
      Navigator.pushNamed(context, nextRoute.nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responses = [
      {'emoji': '👍', 'label': 'Better'},
      {'emoji': '🫳', 'label': 'Same'},
      {'emoji': '👎', 'label': 'Worse'},
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
                'Compared with last month, how are you doing in math?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
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
                      Text(
                        response['emoji']!,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        response['label']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500),
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
