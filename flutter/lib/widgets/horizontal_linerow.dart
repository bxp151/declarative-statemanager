// File: horizontal_linerow.dart

// Utility class for creating a horizontal line row in a table given the number of columns
import 'package:flutter/material.dart';
class HorizontalLineRow {
  static TableRow build({required int columnCount, double height = 2.0, Color color = Colors.black}) {
    return TableRow(
      children: List.generate(
        columnCount,
        (index) => Container(
          height: height,
          color: color,
        ),
      ),
    );
  }
}
