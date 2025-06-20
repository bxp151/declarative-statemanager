// // file: main.dart

// void main() async {
//   runApp(const MyApp()); // Triggers the flutter engine
// }

// /// Flutter engine calls build method
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Build method returns MaterialApp
//     return MaterialApp(
//       initialRoute: '/loadingscreen',
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/teststatelesswidget':
//             return MaterialPageRoute(
//                 builder: (_) => const FirstLoadingScaffold());
//           case '/loadingscreen':
//             return MaterialPageRoute(
//                 builder: (_) => const FirstLoadingScaffold());
//           case '/gradeselectionscreen':
//             return MaterialPageRoute(
//                 builder: (_) => const GradeSelectionScaffold());
//           case '/claimedprogressscreen':
//             return MaterialPageRoute(
//                 builder: (_) => const ClaimedProgressScaffold());
//           case '/mathfeelingsscreen':
//             return MaterialPageRoute(
//                 builder: (_) => const MathFeelingsScaffold());
//           case '/problemloadingscaffold':
//             final isFirst = settings.arguments as bool? ?? true;
//             return MaterialPageRoute(
//               builder: (_) =>
//                   ProblemLoadScaffold(isFirstProblemInSession: isFirst),
//             );
//           case '/problemscreen':
//             return MaterialPageRoute(builder: (_) => problemScreen(context));
//           default:
//             return null;
//         }
//       },
//     );
//   }
// }

// Widget problemScreen(BuildContext context) {
//   return MultiProvider(
//     providers: [
//       ChangeNotifierProvider<GridManager>(create: (_) => GridManager()),
//       ChangeNotifierProvider<StepManager>(create: (_) => StepManager()),
//     ],
//     child: const ProblemScaffold(),
//   );
// }
