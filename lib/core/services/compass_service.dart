import 'package:flutter_compass/flutter_compass.dart';
import 'package:logger/logger.dart';

class CompassService {
  final Logger _logger = Logger();

  Stream<CompassEvent>? get headingStream {
    try {
      return FlutterCompass.events;
    } catch (e) {
      _logger.e('Error getting compass stream: $e');
      return null;
    }
  }
}
