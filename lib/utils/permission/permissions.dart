import 'package:permission_handler/permission_handler.dart';

/// A utility class to handle app permissions.
class AppPermissions {
  /// Requests all necessary permissions required by the app.
  ///
  /// Currently, it requests location permission. Additional permissions
  /// can be added to the list as needed.
  static Future<void> requestAllPermissions() async {
    await [
      Permission.location, // Requesting location permission
    ].request();
  }
}
