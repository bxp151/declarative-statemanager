// FILE: math_problem_grid.dart

import 'package:flutter/material.dart';
import 'grid_renderer.dart';
import '../managers/grid_manager.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/models/problem_data.dart';

/// A widget that displays an interactive grid for solving a math problem.
///
/// This widget uses a [GridManager] to track user input and state changes
/// and updates the UI in response to changes.
class MathProblemGrid extends StatefulWidget {
  /// The [GridManager] instance that handles user input and problem logic.
  final GridManager gridManager;

  /// Creates an instance of [MathProblemGrid].
  const MathProblemGrid({
    super.key,
    required this.gridManager,
  });

  @override
  MathProblemGridState createState() => MathProblemGridState();
}

/// The state for [MathProblemGrid].
///
/// Updates the grid UI in response to changes in the [GridManager].
class MathProblemGridState extends State<MathProblemGrid> {
  ProblemData get currentProblem => ProblemManager().currentProblem;

  @override
  Widget build(BuildContext context) {
    // Ensure proper integration with the Provider-based structure
    final gridManager = widget.gridManager;

    return AnimatedBuilder(
      animation: gridManager, // Listen to changes in GridManager
      builder: (context, _) {
        final gridRenderer = GridRenderer(
          paramGrid:
              currentProblem.paramGrid, // Pass paramGrid from GridManager
          gridManager: gridManager, // Pass the GridManager instance
        );
        return gridRenderer.buildGrid(); // Build and return the rendered grid
      },
    );
  }
}
