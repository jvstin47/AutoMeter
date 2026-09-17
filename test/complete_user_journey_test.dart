import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fare_meter/models/fare_config.dart';
import 'package:smart_fare_meter/services/demo_simulation_service.dart';
import 'package:smart_fare_meter/services/fare_engine.dart';
import 'package:smart_fare_meter/services/payment_service.dart';
import 'package:smart_fare_meter/services/storage_service.dart';
import 'package:smart_fare_meter/services/trip_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Smart Fare Meter End-to-End User Journey', () {
    late StorageService storageService;
    late TripManager tripManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      tripManager = TripManager(storageService);
    });

    tearDown(() {
      tripManager.dispose();
    });

    test('Full Journey: Start Trip -> Driving -> Signal Stop -> Stop Trip -> UPI QR -> Confirm -> History & Earnings', () async {
      // 1. Initial State: Driver dashboard ready
      expect(tripManager.state, TripState.idle);
      expect(tripManager.todayEarnings, 0.0);
      expect(tripManager.todayTripCount, 0);

      // 2. Start Trip
      await tripManager.startTrip();
      expect(tripManager.state, TripState.active);
      expect(tripManager.activeTripId, isNotNull);
      expect(tripManager.currentBreakdown.baseFare, 30.0);
      expect(tripManager.currentBreakdown.totalFare, 30.0);

      // 3. Simulate Vehicle Driving
      tripManager.demoService.setVehicleState(DemoVehicleState.driving);
      tripManager.demoService.setSpeedMultiplier(1.0);

      // Verify FareEngine calculates tariff dynamically
      const config = FareConfig(baseFare: 30.0, perKmRate: 15.0, waitingRatePerMin: 1.5);
      final drivingBreakdown = FareEngine.calculate(
        distanceKm: 4.0, // 4 km driven
        waitingSeconds: 0,
        config: config,
      );
      expect(drivingBreakdown.baseFare, 30.0);
      expect(drivingBreakdown.distanceFare, 60.0); // 4 * 15
      expect(drivingBreakdown.totalFare, 90.0);    // 30 + 60

      // 4. Simulate Signal Stop / Waiting Time
      tripManager.toggleDemoTrafficStop();
      expect(tripManager.isStationary, isTrue);

      final stoppedBreakdown = FareEngine.calculate(
        distanceKm: 4.0,
        waitingSeconds: 120, // 2 minutes waiting
        config: config,
      );
      expect(stoppedBreakdown.waitingMinutes, 2);
      expect(stoppedBreakdown.waitingFare, 3.0);  // 2 * 1.5
      expect(stoppedBreakdown.totalFare, 93.0);   // 30 + 60 + 3

      // 5. Stop Trip
      final completedTrip = await tripManager.stopTrip();
      expect(tripManager.state, TripState.paymentPending);
      expect(completedTrip.id, isNotNull);
      expect(completedTrip.paymentReference, startsWith('MTR-'));

      // 6. Dynamic UPI QR Code Generation
      final upiUri = PaymentService.generateUpiUri(
        upiId: tripManager.driverProfile.upiId,
        payeeName: tripManager.driverProfile.name,
        amount: completedTrip.totalFare,
        transactionNote: 'Auto Rickshaw Fare ${completedTrip.paymentReference}',
        transactionRef: completedTrip.paymentReference!,
      );
      expect(upiUri, contains('upi://pay?'));
      expect(upiUri, contains('am=${completedTrip.totalFare.toStringAsFixed(2)}'));
      expect(upiUri, contains('pa=ramesh.auto@okhdfcbank'));

      // 7. Confirm UPI Payment
      await tripManager.confirmPayment(
        paymentMethod: 'upi',
        paymentStatus: 'confirmed',
      );
      expect(tripManager.state, TripState.completed);

      // 8. Trip Saved in History
      final savedTrips = storageService.getTrips();
      expect(savedTrips.length, 1);
      expect(savedTrips.first.paymentMethod, 'upi');
      expect(savedTrips.first.paymentStatus, 'confirmed');

      // 9. Earnings & Metrics Updated
      expect(tripManager.todayTripCount, 1);
      expect(tripManager.todayEarnings, completedTrip.totalFare);

      // 10. Reset Demo Data for Fresh Presentation
      await tripManager.resetAllDemoData();
      expect(tripManager.trips.isEmpty, isTrue);
      expect(tripManager.todayEarnings, 0.0);
      expect(tripManager.todayTripCount, 0);
      expect(tripManager.state, TripState.idle);
    });
  });
}
