import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/env_config.dart';
import 'providers/theme_provider.dart';
import 'providers/trip_provider.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'ui/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer portrait orientation for rickshaw dashboard mounting
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize offline-first persistent storage
  final storageService = await StorageService.init();

  // Initialize cloud synchronization if configured in environment
  if (EnvConfig.hasSupabaseCredentials) {
    await SupabaseService.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TripProvider(storageService),
        ),
      ],
      child: const SmartFareMeterApp(),
    ),
  );
}

/// Root Application Widget
class SmartFareMeterApp extends StatelessWidget {
  const SmartFareMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'AutoMeter',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const DashboardScreen(),
    );
  }
}
