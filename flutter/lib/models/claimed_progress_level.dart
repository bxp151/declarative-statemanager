// File: claimed_progress_level.dart

class ClaimedProgressLevel {
  final int claimedProgressLevel;

  ClaimedProgressLevel({
    required this.claimedProgressLevel,
  });

  factory ClaimedProgressLevel.fromMap(Map<String, dynamic> map) {
    return ClaimedProgressLevel(
      claimedProgressLevel: map['claimedProgressLevel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'claimedProgressLevel': claimedProgressLevel,
    };
  }
}
