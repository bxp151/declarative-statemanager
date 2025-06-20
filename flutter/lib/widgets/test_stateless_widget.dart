// File: progress_widget

import 'package:flutter/material.dart';

class TestStatelessWidget extends StatelessWidget {
  const TestStatelessWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
}
