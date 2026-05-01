import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/compass_service.dart';
import '../../../core/utils/qibla_calc.dart';

class QiblaViewModel extends ChangeNotifier {
  final LocationService _locationService;
  final CompassService _compassService;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _hasPermissions = false;
  bool get hasPermissions => _hasPermissions;

  double? _userLatitude;
  double? get userLatitude => _userLatitude;

  double? _userLongitude;
  double? get userLongitude => _userLongitude;

  double? _heading; // Device heading from compass
  double? get heading => _heading;

  double? _qiblaBearing; // Bearing to Qibla
  double? get qiblaBearing => _qiblaBearing;

  double? _distanceToQibla; // Distance in meters
  double? get distanceToQibla => _distanceToQibla;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _combinedStreamSubscription;
  int _initToken = 0;

  QiblaViewModel(this._locationService, this._compassService) {
    _init();
  }

  Future<void> _init() async {
    final initToken = ++_initToken;
    await _combinedStreamSubscription?.cancel();
    _combinedStreamSubscription = null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _hasPermissions = await _locationService.handlePermissions();
    if (initToken != _initToken) return;

    if (!_hasPermissions) {
      _errorMessage =
          'Location permissions are required to calculate Qibla direction.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _loadCachedLocation();
    if (initToken != _initToken) return;

    _startStreams();
  }

  Future<void> _loadCachedLocation() async {
    final lastKnownLocation = await _locationService.getLastKnownLocation();
    if (lastKnownLocation != null) {
      _updateLocation(lastKnownLocation.latitude, lastKnownLocation.longitude);
      _isLoading = false;
      notifyListeners();
      return;
    }

    final cachedLocation = await _locationService.getCachedLocation();
    if (cachedLocation != null) {
      _updateLocation(cachedLocation.latitude, cachedLocation.longitude);
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startStreams() {
    final locationStream = _locationService.locationStream;
    final compassStream = _compassService.headingStream;

    if (locationStream == null || compassStream == null) {
      _errorMessage = 'Failed to initialize sensors.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Use RxDart to combine the latest values from both streams
    _combinedStreamSubscription =
        Rx.combineLatest2(locationStream, compassStream, (
          Position position,
          CompassEvent compassEvent,
        ) {
          return {'position': position, 'compass': compassEvent};
        }).listen(
          (data) {
            final position = data['position'] as Position;
            final compassEvent = data['compass'] as CompassEvent;

            unawaited(_locationService.cacheLocation(position));
            _updateLocation(position.latitude, position.longitude);
            _heading = compassEvent.heading;

            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Error receiving sensor data: $error';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _updateLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    _qiblaBearing = QiblaCalc.calculateBearing(latitude, longitude);
    _distanceToQibla = QiblaCalc.calculateDistance(latitude, longitude);
  }

  @override
  void dispose() {
    _initToken++;
    _combinedStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> retryPermissions() async {
    await _init();
  }
}
