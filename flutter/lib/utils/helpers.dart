// file: helpers.dart

class Helpers{

  static int extractIntResult(List<Map<String, dynamic>> queryResult, {int emptyNull = 0, int empty = 0} ) {
  return queryResult.isNotEmpty 
      ? (queryResult.first.values.first as int?) ?? emptyNull
      : empty;
  }
  String getCurrentDate() {
    return DateTime.now().toLocal().toIso8601String().split('T')[0]; // YYYY-MM-DD
  }
}

