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
// file: main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/demo',
      routes: {
        '/demo': (context) => ChangeNotifierProvider(
              create: (_) => BoxColorManager(),
              child: const DemoScaffold(),
            ),
      },
    );
  }
}

class BoxColorManager extends ChangeNotifier {
  Color colorA = Colors.grey;
  Color colorB = Colors.grey;

  void updateColorA(bool isOn) {
    colorA = isOn ? Colors.blue : Colors.grey;
    notifyListeners();
  }

  void updateColorB(bool isOn) {
    colorB = isOn ? Colors.red : Colors.grey;
    notifyListeners();
  }
}

class DemoScaffold extends StatefulWidget {
  const DemoScaffold({super.key});

  @override
  State<DemoScaffold> createState() => _DemoScaffoldState();
}

class _DemoScaffoldState extends State<DemoScaffold> {
  bool switchA = false;
  bool switchB = false;

  void _handleSwitchA(bool value) {
    setState(() {
      switchA = value;
    });
    context.read<BoxColorManager>().updateColorA(value);
  }

  void _handleSwitchB(bool value) {
    setState(() {
      switchB = value;
    });
    context.read<BoxColorManager>().updateColorB(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Manager Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Switch A'),
              onChanged: _handleSwitchA,
              value: switchA,
            ),
            SwitchListTile(
              title: const Text('Switch B'),
              onChanged: _handleSwitchB,
              value: switchB,
            ),
            const SizedBox(height: 32),
            const BoxWidget(label: 'Box A', isBoxA: true),
            const SizedBox(height: 16),
            const BoxWidget(label: 'Box B', isBoxA: false),
          ],
        ),
      ),
    );
  }
}

class BoxWidget extends StatelessWidget {
  final String label;
  final bool isBoxA;

  const BoxWidget({super.key, required this.label, required this.isBoxA});

  @override
  Widget build(BuildContext context) {
    final color = context.select<BoxColorManager, Color>(
      (manager) => isBoxA ? manager.colorA : manager.colorB,
    );

    return Container(
      height: 100,
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
