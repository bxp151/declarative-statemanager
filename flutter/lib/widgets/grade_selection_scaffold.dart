// file: grade_selection_scaffold.dart

import 'package:automath/models/overall_level.dart';
import 'package:flutter/material.dart';
import 'package:automath/daos/overall_level_dao.dart';
import 'package:automath/daos/param_level_dao.dart';
import 'package:automath/models/param_level.dart';
import 'package:automath/daos/next_route_dao.dart';

class GradeSelectionScaffold extends StatefulWidget {
  const GradeSelectionScaffold({super.key});

  @override
  State<GradeSelectionScaffold> createState() => _GradeSelectionScaffoldState();
}

class _GradeSelectionScaffoldState extends State<GradeSelectionScaffold> {
  final grades = ['K', '1', '2', '3', '4', '5'];

  void _handleGradeTap(String grade) async {
    final gradeNum = (grade == 'K') ? '0' : grade;
    final overallLevel = await OverallLevelDao()
        .getFirstOverallLevelFromGradeLevel(gradeLevel: int.parse(gradeNum));
    await OverallLevelDao()
        .insertOverallLevelLog(OverallLevel(currentOverallLevel: overallLevel));
    await ParamLevelDao().insertParamLevelLog(ParamLevel(currentParamLevel: 0));

    // Get next route
    final nextRoute = await NextRouteDao().getNextRoute();
    if (mounted) {
      Navigator.pushNamed(context, nextRoute.nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What grade are you in?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Wrap(
                spacing: 50,
                runSpacing: 50,
                alignment: WrapAlignment.center,
                children: grades.map((grade) {
                  return GestureDetector(
                    onTap: () => _handleGradeTap(grade),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.3 * 255).round()),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        grade,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _GradeSelectionScaffoldState extends State<GradeSelectionScaffold> {
//   @override
//   Widget build(BuildContext context) {
//     final grades = ['K', '1', '2', '3', '4', '5'];

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'What grade are you in?',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 36,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 80),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 28.0),
//               child: Wrap(
//                 spacing: 50, // horizontal space between items
//                 runSpacing: 50, // vertical space between rows
//                 alignment: WrapAlignment.center,
//                 children: grades.map((grade) {
//                   return GestureDetector(
//                     onTap: () async {
//                       final gradeNum = (grade == 'K') ? '0' : grade;
//                       final overallLevel = await OverallLevelDao()
//                           .getFirstOverallLevelFromGradeLevel(
//                               gradeLevel: int.parse(gradeNum));
//                       if (!mounted) return;

//                       OverallLevelDao().insertOverallLevelLog(overallLevel);
//                       ParamLevelDao().insertParamLevelLog(
//                           ParamLevel(currentParamLevel: 0));
//                       Navigator.pushNamed(context, '/nextScreen');
//                     },
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withAlpha((0.3 * 255).round()),
//                             blurRadius: 4,
//                             offset: const Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         grade,
//                         style: const TextStyle(
//                           fontSize: 36,
//                           color: Colors.black,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
