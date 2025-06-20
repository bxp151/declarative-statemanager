// File: next_route.dart

class NextRoute {
  final String nextRoute;

  NextRoute({
    required this.nextRoute,
  });

  factory NextRoute.fromMap(Map<String, dynamic> map) {
    return NextRoute(
      nextRoute: map['route'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'route': nextRoute,
    };
  }
}
