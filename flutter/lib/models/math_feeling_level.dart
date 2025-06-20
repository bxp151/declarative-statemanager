// File: math_feeling_level.dart

class MathFeelingLevel {
  final int mathFeelingLevel;

  MathFeelingLevel({
    required this.mathFeelingLevel,
  });

  factory MathFeelingLevel.fromMap(Map<String, dynamic> map) {
    return MathFeelingLevel(
      mathFeelingLevel: map['mathFeelingLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mathFeelingLevel': mathFeelingLevel,
    };
  }
}
