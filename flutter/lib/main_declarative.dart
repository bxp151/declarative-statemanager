// file: main.dart
import 'package:flutter/material.dart';

void main() {
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
  final GlobalKey<BoxWidgetState> boxAkey = GlobalKey<BoxWidgetState>();
  final GlobalKey<BoxWidgetState> boxBkey = GlobalKey<BoxWidgetState>();

  bool switchA = false;
  bool switchB = false;

  void _handleSwitchA(bool value) {
    setState(() {
      switchA = value;
    });
    print("Switch A toggled: $value");
  }

  void _handleSwitchB(bool value) {
    setState(() {
      switchB = value;
    });
    print("Switch B toggled: $value");
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
