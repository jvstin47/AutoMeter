import 'package:flutter/material.dart';
import '../../core/theme/meter_theme_colors.dart';

/// Glassmorphic "Weather + Battery" Pill Component
/// Essential for drivers in open auto-rickshaw cabins to monitor device heat and charging health.
class WeatherBatteryPill extends StatelessWidget {
  final String temperature;
  final String batteryLevel;
  final bool isCharging;

  const WeatherBatteryPill({
    super.key,
    this.temperature = '32°C',
    this.batteryLevel = '88%',
    this.isCharging = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.meterColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.card.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Weather Item
          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFD54F), size: 16),
          const SizedBox(width: 5),
          Text(
            temperature,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),

          // Vertical Hardware Divider
          Container(
            height: 12,
            width: 1,
            color: colors.divider,
          ),
          const SizedBox(width: 8),

          // Battery Item
          Icon(
            isCharging
                ? Icons.battery_charging_full_rounded
                : Icons.battery_std_rounded,
            color: const Color(0xFF00E676),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            batteryLevel,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
