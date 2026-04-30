import 'package:geolocator/geolocator.dart';
import 'constants.dart';

class QiblaCalc {
  /// Calculate bearing from a given location to the Ka'bah
  static double calculateBearing(double userLat, double userLon) {
    // geolocator returns bearing in degrees (-180 to 180)
    double bearing = Geolocator.bearingBetween(
      userLat,
      userLon,
      AppConstants.kabahLatitude,
      AppConstants.kabahLongitude,
    );

    // Convert to 0 - 360 degrees
    if (bearing < 0) {
      bearing += 360;
    }
    return bearing;
  }

  /// Calculate distance in meters from a given location to the Ka'bah
  static double calculateDistance(double userLat, double userLon) {
    return Geolocator.distanceBetween(
      userLat,
      userLon,
      AppConstants.kabahLatitude,
      AppConstants.kabahLongitude,
    );
  }
}
