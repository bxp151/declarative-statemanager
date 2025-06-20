// File: overall_level_log.dart

class OverallLevel {
  final int currentOverallLevel;

  OverallLevel({
    required this.currentOverallLevel,
  });

  factory OverallLevel.fromMap(Map<String, dynamic> map) {
    return OverallLevel(
      currentOverallLevel: map['currentOverallLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentOverallLevel': currentOverallLevel,
    };
  }
}
