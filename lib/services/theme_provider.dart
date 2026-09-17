import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/meter_theme.dart';
import 'storage_service.dart';

enum AppThemeMode {
  amoled,
  slate,
  light,
  system;

  String get label {
    switch (this) {
      case AppThemeMode.amoled:
        return 'AMOLED Pitch Black';
      case AppThemeMode.slate:
        return 'Midnight Slate';
      case AppThemeMode.light:
        return 'Sunlight Day Mode';
      case AppThemeMode.system:
        return 'Follow System';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.amoled:
        return 'Pure #000000 OLED black, zero cabin glare & maximum battery savings';
      case AppThemeMode.slate:
        return 'Deep matte automotive charcoal with dark slate surfaces';
      case AppThemeMode.light:
        return 'High-contrast, anti-glare daylight theme for direct sun windshield visibility';
      case AppThemeMode.system:
        return 'Automatically matches your device light or dark mode schedule';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.amoled:
        return Icons.brightness_2_rounded;
      case AppThemeMode.slate:
        return Icons.dark_mode_rounded;
      case AppThemeMode.light:
        return Icons.wb_sunny_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  static AppThemeMode fromString(String val) {
    switch (val.toLowerCase()) {
      case 'slate':
        return AppThemeMode.slate;
      case 'light':
        return AppThemeMode.light;
      case 'system':
        return AppThemeMode.system;
      case 'amoled':
      default:
        return AppThemeMode.amoled;
    }
  }
}

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  late AppThemeMode _currentMode;

  ThemeProvider(this._storageService) {
    final savedMode = _storageService.getThemeMode();
    _currentMode = AppThemeMode.fromString(savedMode);
    _applySystemOverlay();
  }

  AppThemeMode get currentMode => _currentMode;

  ThemeMode get themeMode {
    switch (_currentMode) {
      case AppThemeMode.amoled:
      case AppThemeMode.slate:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData get currentTheme => MeterTheme.getTheme(_currentMode);

  ThemeData get darkTheme => _currentMode == AppThemeMode.slate
      ? MeterTheme.slateTheme
      : MeterTheme.amoledTheme;

  ThemeData get lightTheme => MeterTheme.lightTheme;

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentMode == mode) return;
    _currentMode = mode;
    await _storageService.saveThemeMode(mode.name);
    _applySystemOverlay();
    notifyListeners();
  }

  Future<void> cycleTheme() async {
    final next = switch (_currentMode) {
      AppThemeMode.amoled => AppThemeMode.slate,
      AppThemeMode.slate => AppThemeMode.light,
      AppThemeMode.light => AppThemeMode.amoled,
      AppThemeMode.system => AppThemeMode.amoled,
    };
    await setThemeMode(next);
  }

  void _applySystemOverlay() {
    switch (_currentMode) {
      case AppThemeMode.amoled:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF000000),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );
        break;
      case AppThemeMode.slate:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF0A0C10),
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );
        break;
      case AppThemeMode.light:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Color(0xFFF4F6F9),
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );
        break;
      case AppThemeMode.system:
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF000000),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        );
        break;
    }
  }
}
