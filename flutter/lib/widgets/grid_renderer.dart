// FILE: grid_renderer.dart

import 'package:flutter/material.dart';
import 'package:automath/managers/grid_manager.dart';
import 'package:automath/managers/step_manager.dart';

/// GridRenderer:
/// - A utility class for rendering a grid-based UI using a [Table] widget.
///
/// Parameters:
/// - [paramGrid]: A map representing the grid structure to be displayed.
/// - [gridManager]: An instance of [GridManager] to handle user inputs and validation.
///
/// Features:
/// - Dynamically generates rows and cells based on the grid structure.
/// - Displays editable cells for user input with validation feedback.
///
/// Notes:
/// - Editable cells are indicated by a grey background for unvalidated states.
///
import 'horizontal_linerow.dart';

class GridRenderer {
  final Map<String, dynamic> paramGrid; // The grid structure
  final GridManager gridManager; // Manages user inputs and validation

  StepManager get stepManager => StepManager();

  GridRenderer({required this.paramGrid, required this.gridManager});

  Table buildGrid() {
    // print("Rebuilding entire grid");

    // Use a key tied to the grid state to force a full rebuild
    final tableKey = ValueKey(gridManager.userInputs.hashCode);

    final rows = <TableRow>[];

    // Iterate through the rows of the grid
    for (var entry in paramGrid.entries) {
      final rowKey = entry.key;
      final values = entry.value as List<dynamic>;

      // Adds a line before the answer row
      if (rowKey == "A|") {
        rows.add(HorizontalLineRow.build(columnCount: values.length));
      }

      // Calls buildTableRow to add the <TableRow>
      rows.add(buildTableRow(rowKey, values));
    }

    return Table(
      key: tableKey, // Force the entire table to rebuild
      // border: TableBorder.all(), // Optional: Modify this if you need different borders
      children: rows,
    );
  }

  /// Builds a single table row.
  TableRow buildTableRow(String rowKey, List<dynamic> values) {
    // print("Rebuilding row: $rowKey");

    // rowKey = "A|"
    // values = ["A", "B", "C"]

    final cells = <Widget>[];

    for (int index = 0; index < values.length; index++) {
      final value = values[index];
      final cellKey = gridManager.generateKey(
          rowKey, index); // Generate the cell's unique key "A|1"
      final isLocked =
          stepManager.isCellLocked(cellKey); // Check if the cell is locked

      final isCellinIncorrectStep = stepManager.isCellinIncorrectStep(cellKey);

      if (value is String && RegExp(r'^[A-Za-z]$').hasMatch(value)) {
        cells.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              GestureDetector(
                // <### CHANGED ###>
                onTap: () {
                  // <### CHANGED ###>
                  if (isCellinIncorrectStep) {
                    // <### CHANGED ###>
                    gridManager.unlockCellsInStep(rowKey, index);
                    gridManager.deleteCellsInStep(rowKey, index);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: stepManager.getCellBackgroundColor(rowKey, index),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: TextField(
                    key: ValueKey(gridManager.userInputs[cellKey] ??
                        ''), // <### CHANGED ###>
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 30),
                    enabled:
                        !isLocked, // Disable the TextField if the cell is locked
                    onChanged: (value) {
                      if (value.isEmpty) {
                        gridManager.resetValidationState(rowKey, index);
                      } else {
                        gridManager.processInputAndAdvance(
                            rowKey, index, value);
                      }
                    },
                    controller: TextEditingController(
                      // <### CHANGED ###>
                      text: gridManager.userInputs[cellKey] ??
                          '', // <### CHANGED ###>
                    ), // <### CHANGED ###>
                  ),
                ),
              ),
              if (stepManager.shouldShowCheckIcon(rowKey, index))
                const Icon(
                  Icons.check,
                  color: Color(0xFF002060), // Dark blue
                  size: 24,
                ),
              if (stepManager.shouldShowXIconNew(rowKey, index))
                const Icon(
                  Icons.close,
                  color: Color(0xFFE97132), // Dark orange
                  size: 24,
                ),
            ],
          ),
        ));
      } else {
        // Static text (e.g., numbers, operators)
        cells.add(SizedBox(
          height: 50,
          child: Center(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 35),
            ),
          ),
        ));
      }
    }

    return TableRow(children: cells);
  }
}
