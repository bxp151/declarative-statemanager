// File: param_level.dart

class ParamLevel {
  final int currentParamLevel;

  ParamLevel({
    required this.currentParamLevel,
  });

  factory ParamLevel.fromMap(Map<String, dynamic> map) {
    return ParamLevel(
      currentParamLevel: map['currentParamLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentParamLevel': currentParamLevel,
    };
  }
}
