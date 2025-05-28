import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for managing shared preferences.
///
/// This class provides static methods for storing and retrieving
/// various types of data using `SharedPreferences`.
class SharedPreferencesHelper {
  /// SharedPreferences instance
  static late SharedPreferences _prefs;

  /// Initializes the SharedPreferences instance.
  ///
  /// This method **must** be called before using any other method in this class.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ======================== Save Data ========================

  /// Saves a string value in shared preferences.
  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Saves an integer value in shared preferences.
  static Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Saves a boolean value in shared preferences.
  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Saves a list of strings in shared preferences.
  static Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // ======================== Retrieve Data ========================

  /// Retrieves a string value from shared preferences.
  static Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  /// Retrieves an integer value from shared preferences.
  static Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  /// Retrieves a boolean value from shared preferences.
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Retrieves a list of strings from shared preferences.
  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // ======================== Remove/Clear Data ========================

  /// Removes a specific key and its associated value from shared preferences.
  static Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }

  /// Clears all stored preferences.
  static Future<void> clear() async {
    await _prefs.clear();
  }
}
