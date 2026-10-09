import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fare_meter/core/theme/meter_theme.dart';
import 'package:smart_fare_meter/models/fare_config.dart';
import 'package:smart_fare_meter/models/trip_model.dart';
import 'package:smart_fare_meter/services/storage_service.dart';
import 'package:smart_fare_meter/services/theme_provider.dart';
import 'package:smart_fare_meter/services/trip_manager.dart';
import 'package:smart_fare_meter/ui/screens/dashboard_screen.dart';
import 'package:smart_fare_meter/ui/screens/live_meter_screen.dart';
import 'package:smart_fare_meter/ui/screens/passenger_mode_screen.dart';
import 'package:smart_fare_meter/ui/screens/payment_qr_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({
    required Widget child,
    required StorageService storage,
    required TripManager tripManager,
    AppThemeMode themeMode = AppThemeMode.slate,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage)..setThemeMode(themeMode),
        ),
        ChangeNotifierProvider.value(
          value: tripManager,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: MeterTheme.getTheme(tp.currentMode),
          home: child,
        ),
      ),
    );
  }

  testWidgets('Render and verify Dashboard Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final manager = TripManager(storage);

    await tester.pumpWidget(
      buildTestApp(
        child: const DashboardScreen(),
        storage: storage,
        tripManager: manager,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(DashboardScreen),
      matchesGoldenFile('goldens/01_dashboard_screen.png'),
    );
  });

  testWidgets('Render and verify Live Meter HUD Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final manager = TripManager(storage);
    await manager.startTrip();
    manager.pauseTimersForTesting();

    await tester.pumpWidget(
      buildTestApp(
        child: const LiveMeterScreen(),
        storage: storage,
        tripManager: manager,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final ex = tester.takeException();
    expect(ex, isNull);
    await expectLater(
      find.byType(LiveMeterScreen),
      matchesGoldenFile('goldens/02_live_meter_hud.png'),
    );
    await manager.stopTrip();
  });

  testWidgets('Render and verify Passenger Mode Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final manager = TripManager(storage);
    await manager.startTrip();
    manager.pauseTimersForTesting();

    await tester.pumpWidget(
      buildTestApp(
        child: const PassengerModeScreen(),
        storage: storage,
        tripManager: manager,
        themeMode: AppThemeMode.amoled,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final ex = tester.takeException();
    await manager.stopTrip();
    expect(ex, isNull);
    await expectLater(
      find.byType(PassengerModeScreen),
      matchesGoldenFile('goldens/03_passenger_mode.png'),
    );
  });

  testWidgets('Render and verify Payment QR Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();
    final manager = TripManager(storage);

    final mockTrip = TripModel(
      id: 'trip-preview-test-01',
      startTime: DateTime.now().subtract(const Duration(minutes: 18)),
      endTime: DateTime.now(),
      distanceKm: 5.42,
      waitingDurationSeconds: 240,
      tripDurationSeconds: 1080,
      baseFare: 30.0,
      distanceFare: 81.30,
      waitingFare: 6.0,
      totalFare: 117.30,
      paymentMethod: 'upi',
      paymentStatus: 'pending',
      paymentReference: 'UPI-MTR-98214',
      isDemo: true,
      isSynced: false,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      buildTestApp(
        child: PaymentQrScreen(trip: mockTrip),
        storage: storage,
        tripManager: manager,
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(PaymentQrScreen),
      matchesGoldenFile('goldens/04_payment_qr.png'),
    );
  });
}
