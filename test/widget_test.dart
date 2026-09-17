import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fare_meter/main.dart';
import 'package:smart_fare_meter/services/storage_service.dart';
import 'package:smart_fare_meter/services/theme_provider.dart';
import 'package:smart_fare_meter/services/trip_manager.dart';

void main() {
  testWidgets('Smart Fare Meter dashboard renders and displays ready status', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(storageService),
          ),
          ChangeNotifierProvider(
            create: (_) => TripManager(storageService),
          ),
        ],
        child: const SmartFareMeterApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header and ready status
    expect(find.text('AUTOMETER'), findsOneWidget);
    expect(find.text('YOUR METER IS READY'), findsOneWidget);
    expect(find.text('START TRIP'), findsOneWidget);
    expect(find.text("TODAY'S OVERVIEW"), findsOneWidget);
  });
}
