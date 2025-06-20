// File: session_manager.dart

class SessionManager {

  static final SessionManager _instance = SessionManager._internal(); // Singleton instance

  factory SessionManager() => _instance; // Always return the same instance

  SessionManager._internal(); // Private constructor

  final int _sessionID = 1; // Session ID Static for now

  int get sessionID => _sessionID; // Getter for sessionID

}