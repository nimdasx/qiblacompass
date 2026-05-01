import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedLocation {
  final double latitude;
  final double longitude;

  const CachedLocation({required this.latitude, required this.longitude});
}

class LocationService {
  static const _cachedLatitudeKey = 'cached_location_latitude';
  static const _cachedLongitudeKey = 'cached_location_longitude';

  final Logger _logger = Logger();

  Stream<Position>? get locationStream {
    try {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Updates every 10 meters
        ),
      );
    } catch (e) {
      _logger.e('Error getting location stream: $e');
      return null;
    }
  }

  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      _logger.e('Error getting last known location: $e');
      return null;
    }
  }

  Future<CachedLocation?> getCachedLocation() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final latitude = preferences.getDouble(_cachedLatitudeKey);
      final longitude = preferences.getDouble(_cachedLongitudeKey);

      if (latitude == null || longitude == null) {
        return null;
      }

      return CachedLocation(latitude: latitude, longitude: longitude);
    } catch (e) {
      _logger.e('Error getting cached location: $e');
      return null;
    }
  }

  Future<void> cacheLocation(Position position) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setDouble(_cachedLatitudeKey, position.latitude);
      await preferences.setDouble(_cachedLongitudeKey, position.longitude);
    } catch (e) {
      _logger.e('Error caching location: $e');
    }
  }

  Future<bool> handlePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.w(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return false;
    }

    return true;
  }
}
