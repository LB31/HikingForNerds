import 'package:location_permissions/location_permissions.dart';

class LocationService {
  static bool _isCurrentlyGranting = false;

  static Future<bool> isLocationPermissionGranted() async {
    PermissionStatus permission =
    await LocationPermissions().checkPermissionStatus();
    return permission  == PermissionStatus.granted;
  }

  static Future<void> requestLocationPermissionIfNotAlreadyGranted() async {
    bool granted = await isLocationPermissionGranted();

    if (!granted && !_isCurrentlyGranting) {
      _isCurrentlyGranting = true;
      await LocationPermissions().requestPermissions();
      _isCurrentlyGranting = false;
      granted = await isLocationPermissionGranted();
    }
  }
}