// File: progress_widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automath/managers/grid_manager.dart';
import 'package:automath/managers/problem_manager.dart';
import 'package:automath/models/problem_data.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({super.key});

  ProblemData get currentProblem => ProblemManager().currentProblem;

  @override
  Widget build(BuildContext context) {
    final numSteps = currentProblem.numSteps;
    final numStepsComplete = context.watch<GridManager>().numStepsCompleteNew;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        numSteps,
        (index) {
          final isCompleted = index < numStepsComplete;

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Color(0xFF002060) : Colors.white,
                ),
              ),
              if (!isCompleted) // Show the number only if the step is incomplete
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              if (isCompleted) // Show the checkmark for completed steps
                const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          );
        },
      ),
    );
  }
}
