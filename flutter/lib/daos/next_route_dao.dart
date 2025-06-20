// file: next_route_dao.dart

import 'package:automath/services/schema/database_table_service.dart';
import 'package:automath/models/next_route.dart';

class NextRouteDao {
  // Singleton instance
  static final NextRouteDao _instance = NextRouteDao._internal();
  factory NextRouteDao() => _instance;
  NextRouteDao._internal();

  final DatabaseTableService _dbService =
      DatabaseTableService(); // Reference to DatabaseService

  Future<NextRoute> getNextRoute() async {
    final db = await _dbService.database; // Get database instance

    // Query to get the next route
    final map = await db.rawQuery('''
    SELECT route
      FROM ui_preflow_all_view
    LIMIT 1
    ''');

    // If there is a level in the DB, return it
    if (map.isNotEmpty) {
      // gets the first row from the query return
      final firstRow = map.first;
      // Converts the map to a model object
      final objNextRoute = NextRoute.fromMap(firstRow);
      return objNextRoute;
    } else {
      // Else throw an error
      throw Exception('No NextRoute found');
    }
  }
}
