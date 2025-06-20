// file: main.dart
import 'package:flutter/material.dart';
import 'package:demo/managers/dispatch_manager.dart';
import 'package:demo/managers/state_manager.dart';
import 'package:demo/services/database_table_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final stateDb = await DatabaseTableService().database;

  // await DatabaseViewService().createOrReplaceViews(stateDb);
  // await StateManager().startEvaluatorLoop();
  runApp(const MyApp());
}

// Entry point widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/demo',
      routes: {
        '/demo': (context) => const DemoScaffold(),
      },
    );
  }
}

// Demo scaffold with switches and boxes
class DemoScaffold extends StatefulWidget {
  const DemoScaffold({super.key});

  @override
  State<DemoScaffold> createState() => _DemoScaffoldState();
}

class _DemoScaffoldState extends State<DemoScaffold> {
  // Create the GlobalKeys used access and update BoxWidget states
  final GlobalKey<BoxWidgetState> boxAkey = GlobalKey<BoxWidgetState>();
  final GlobalKey<BoxWidgetState> boxBkey = GlobalKey<BoxWidgetState>();

  Future<void> _runPostFrameAsync() async {
    // if (stateLogIDswitchA != null) {}

    // if (stateLogIDswitchB != null) {}
    // Example async code
    // await Future.delayed(Duration(milliseconds: 100));
    // boxAkey.currentState?.updateColor(Colors.blue);
    // boxBkey.currentState?.updateColor(Colors.deepOrangeAccent);
  }

  @override
  void initState() {
    super.initState();
    // Register GlobalKeys with DispatchManager for external state control
    DispatchManager().registerBoxAkey(boxAkey);
    DispatchManager().registerBoxBkey(boxBkey);

    // This runs after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _runPostFrameAsync();
    });
  }

  bool switchA = false;
  bool switchB = false;

  late int? stateLogIDswitchA;
  late int? stateLogIDswitchB;

  Future<void> handleSwitchA(bool value) async {
    setState(() {
      switchA = value;
    });
    // Insert entry into State Log table when switch A changes
    stateLogIDswitchA = await StateManager().insertStateLogEntry(
        originWidget: widget.runtimeType.toString(),
        originMethod: 'handleSwitchA',
        stateName: 'switchAvalue',
        stateValue: switchA.toString());
    print("Switch A toggled: $value");
  }

  Future<void> _handleSwitchB(bool value) async {
    setState(() {
      switchB = value;
    });
    // Insert entry into State Log table when switch B changes
    stateLogIDswitchB = await StateManager().insertStateLogEntry(
        originWidget: widget.runtimeType.toString(),
        originMethod: 'handleSwitchB',
        stateName: 'switchBvalue',
        stateValue: switchB.toString());
    print("Switch B toggled: $value");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Declarative State')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Switch A'),
              onChanged: handleSwitchA,
              value: switchA,
            ),
            SwitchListTile(
              title: const Text('Switch B'),
              onChanged: _handleSwitchB,
              value: switchB,
            ),
            const SizedBox(height: 32),
            BoxWidget(key: boxAkey, label: 'Box A'),
            const SizedBox(height: 16),
            BoxWidget(key: boxBkey, label: 'Box B'),
          ],
        ),
      ),
    );
  }
}

// Minimal placeholder box widget
class BoxWidget extends StatefulWidget {
  final String label;

  const BoxWidget({super.key, required this.label});

  @override
  State<BoxWidget> createState() => BoxWidgetState();
}

class BoxWidgetState extends State<BoxWidget> {
  Color _boxColor = Colors.grey;

  void updateColor(Color color) {
    setState(() {
      _boxColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: _boxColor,
      alignment: Alignment.center,
      child: Text(
        widget.label,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
