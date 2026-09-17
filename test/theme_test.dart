import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fare_meter/core/theme/meter_theme.dart';
import 'package:smart_fare_meter/core/theme/meter_theme_colors.dart';
import 'package:smart_fare_meter/services/storage_service.dart';
import 'package:smart_fare_meter/services/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Architecture Tests', () {
    test('AppThemeMode parsing and metadata', () {
      expect(AppThemeMode.fromString('amoled'), AppThemeMode.amoled);
      expect(AppThemeMode.fromString('slate'), AppThemeMode.slate);
      expect(AppThemeMode.fromString('light'), AppThemeMode.light);
      expect(AppThemeMode.fromString('system'), AppThemeMode.system);
      expect(AppThemeMode.fromString('unknown'), AppThemeMode.amoled);

      expect(AppThemeMode.amoled.label, 'AMOLED Pitch Black');
      expect(AppThemeMode.slate.label, 'Midnight Slate');
      expect(AppThemeMode.light.label, 'Sunlight Day Mode');
      expect(AppThemeMode.system.label, 'Follow System');
    });

    test('MeterThemeColors provides distinct palettes for AMOLED, Slate, and Light', () {
      // AMOLED Pure Black
      expect(MeterThemeColors.amoled.bg, const Color(0xFF000000));
      expect(MeterThemeColors.amoled.surface, const Color(0xFF0D0D0F));

      // Midnight Slate
      expect(MeterThemeColors.slate.bg, const Color(0xFF0A0C10));
      expect(MeterThemeColors.slate.surface, const Color(0xFF131722));

      // Sunlight Day Mode
      expect(MeterThemeColors.light.bg, const Color(0xFFF4F6F9));
      expect(MeterThemeColors.light.surface, const Color(0xFFFFFFFF));
      expect(MeterThemeColors.light.textPrimary, const Color(0xFF0F172A));
    });

    test('MeterTheme builds valid ThemeData for all modes', () {
      final amoled = MeterTheme.getTheme(AppThemeMode.amoled);
      expect(amoled.brightness, Brightness.dark);
      expect(amoled.scaffoldBackgroundColor, const Color(0xFF000000));

      final slate = MeterTheme.getTheme(AppThemeMode.slate);
      expect(slate.brightness, Brightness.dark);
      expect(slate.scaffoldBackgroundColor, const Color(0xFF0A0C10));

      final light = MeterTheme.getTheme(AppThemeMode.light);
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, const Color(0xFFF4F6F9));
    });

    test('ThemeProvider manages and persists theme changes', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final provider = ThemeProvider(storage);

      // Default is AMOLED
      expect(provider.currentMode, AppThemeMode.amoled);
      expect(provider.themeMode, ThemeMode.dark);

      // Switch to Slate
      await provider.setThemeMode(AppThemeMode.slate);
      expect(provider.currentMode, AppThemeMode.slate);
      expect(storage.getThemeMode(), 'slate');

      // Cycle through themes
      await provider.cycleTheme(); // slate -> light
      expect(provider.currentMode, AppThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);

      await provider.cycleTheme(); // light -> amoled
      expect(provider.currentMode, AppThemeMode.amoled);
      expect(provider.themeMode, ThemeMode.dark);
    });
  });
}
