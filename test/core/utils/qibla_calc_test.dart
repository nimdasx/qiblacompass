import 'package:flutter_test/flutter_test.dart';
import 'package:qiblacompass/core/utils/constants.dart';
import 'package:qiblacompass/core/utils/qibla_calc.dart';

void main() {
  group('QiblaCalc', () {
    test('returns zero distance at the Kaabah coordinates', () {
      final distance = QiblaCalc.calculateDistance(
        AppConstants.kabahLatitude,
        AppConstants.kabahLongitude,
      );

      expect(distance, closeTo(0, 0.01));
    });

    test('calculates the expected Qibla bearing from Jakarta', () {
      final bearing = QiblaCalc.calculateBearing(-6.2088, 106.8456);

      expect(bearing, closeTo(295.2, 0.5));
    });

    test('calculates the expected distance from Jakarta to the Kaabah', () {
      final distance = QiblaCalc.calculateDistance(-6.2088, 106.8456);

      expect(distance / 1000, closeTo(7929, 10));
    });
  });
}
