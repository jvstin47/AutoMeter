import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/meter_theme.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'services/trip_manager.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer portrait orientation for meter mounting
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay styling for dark industrial theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0C10),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline-first storage
  final storageService = await StorageService.init();

  // Initialize Supabase if environment/config exists (graceful offline fallback)
  // For production/demo, replace with project specific credentials if available
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await SupabaseService.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripManager(storageService),
        ),
      ],
      child: const SmartFareMeterApp(),
    ),
  );
}

class SmartFareMeterApp extends StatelessWidget {
  const SmartFareMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoMeter',
      debugShowCheckedModeBanner: false,
      theme: MeterTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
