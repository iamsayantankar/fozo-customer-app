import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCheckPermissionLocation() async {
  if (await Permission.location.status.isGranted) {
    return true;
  }else if (await Permission.location.request().isGranted) {
    return true;
  } else if (await Permission.location.request().isDenied) {
    openAppSettings();
  } else if (await Permission.location.request().isPermanentlyDenied) {
    openAppSettings();
  }
  return false;
}