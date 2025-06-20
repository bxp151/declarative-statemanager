// File: set_manager.dart

class SetManager {

  static final SetManager _instance = SetManager._internal(); // Singleton instance
  factory SetManager() => _instance; // Always return the same instance
  SetManager._internal(); // Private constructor
  
  final int _setID = 1; // Set ID Static for now
  int get setID => _setID; // Getter for setID
}