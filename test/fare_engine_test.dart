import 'package:flutter_test/flutter_test.dart';
import 'package:smart_fare_meter/models/fare_config.dart';
import 'package:smart_fare_meter/services/fare_engine.dart';

void main() {
  group('FareEngine Tests', () {
    test('Calculates base fare at 0 distance and 0 waiting', () {
      const config = FareConfig(
        baseFare: 30.0,
        perKmRate: 15.0,
        waitingRatePerMin: 1.5,
      );

      final result = FareEngine.calculate(
        distanceKm: 0.0,
        waitingSeconds: 0,
        config: config,
      );

      expect(result.baseFare, 30.0);
      expect(result.distanceFare, 0.0);
      expect(result.waitingFare, 0.0);
      expect(result.totalFare, 30.0);
      expect(result.baseFare + result.distanceFare + result.waitingFare, result.totalFare);
    });

    test('Calculates spec example (3.6 km @ 10/km, 3 min waiting @ 2/min)', () {
      const config = FareConfig(
        baseFare: 40.0,
        perKmRate: 10.0,
        waitingRatePerMin: 2.0,
      );

      final result = FareEngine.calculate(
        distanceKm: 3.6,
        waitingSeconds: 180, // 3 minutes
        config: config,
      );

      expect(result.baseFare, 40.0);
      expect(result.distanceFare, 36.0);
      expect(result.waitingMinutes, 3);
      expect(result.waitingFare, 6.0);
      expect(result.totalFare, 82.0);
    });

    test('Ceils partial waiting minutes realistically', () {
      const config = FareConfig(
        baseFare: 30.0,
        perKmRate: 15.0,
        waitingRatePerMin: 1.5,
      );

      // 75 seconds is 1m 15s -> ceils to 2 minutes
      final result = FareEngine.calculate(
        distanceKm: 2.0,
        waitingSeconds: 75,
        config: config,
      );

      expect(result.waitingMinutes, 2);
      expect(result.waitingFare, 3.0); // 2 * 1.5
      expect(result.distanceFare, 30.0); // 2 * 15
      expect(result.totalFare, 63.0); // 30 + 30 + 3
    });

    test('Supports minimum distance included in base fare', () {
      // Base fare 30 covers first 2.0 km. Above that, 15/km.
      const configWithMinDist = FareConfig(
        baseFare: 30.0,
        perKmRate: 15.0,
        waitingRatePerMin: 1.5,
        minDistanceKm: 2.0,
      );

      // Trip 1: 1.5 km (within base distance) -> 0 distance charge
      final withinBase = FareEngine.calculate(
        distanceKm: 1.5,
        waitingSeconds: 0,
        config: configWithMinDist,
      );
      expect(withinBase.baseFare, 30.0);
      expect(withinBase.chargeableDistanceKm, 0.0);
      expect(withinBase.distanceFare, 0.0);
      expect(withinBase.totalFare, 30.0);

      // Trip 2: 5.0 km (3.0 km chargeable above 2.0 km) -> 3 * 15 = 45
      final aboveBase = FareEngine.calculate(
        distanceKm: 5.0,
        waitingSeconds: 0,
        config: configWithMinDist,
      );
      expect(aboveBase.baseFare, 30.0);
      expect(aboveBase.chargeableDistanceKm, 3.0);
      expect(aboveBase.distanceFare, 45.0);
      expect(aboveBase.totalFare, 75.0); // 30 + 45
    });

    test('Handles negative or invalid input values safely', () {
      const config = FareConfig(
        baseFare: 30.0,
        perKmRate: 15.0,
        waitingRatePerMin: 1.5,
      );

      final result = FareEngine.calculate(
        distanceKm: -5.0,
        waitingSeconds: -100,
        config: config,
      );

      expect(result.distanceKm, 0.0);
      expect(result.waitingDurationSeconds, 0);
      expect(result.totalFare, 30.0);
    });

    test('Breakdown always matches total fare', () {
      const config = FareConfig(
        baseFare: 30.0,
        perKmRate: 15.25,
        waitingRatePerMin: 1.75,
      );

      final result = FareEngine.calculate(
        distanceKm: 4.82,
        waitingSeconds: 215, // 4 min
        config: config,
        roundToNearestRupee: false,
      );

      final expectedSum = result.baseFare + result.distanceFare + result.waitingFare;
      expect(result.totalFare, double.parse(expectedSum.toStringAsFixed(2)));
    });
  });
}
