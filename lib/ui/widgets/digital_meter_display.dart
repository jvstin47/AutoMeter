import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../core/utils/formatters.dart';

class DigitalMeterDisplay extends StatelessWidget {
  final double totalFare;
  final double distanceKm;
  final int waitingSeconds;
  final int tripDurationSeconds;
  final double speedKmh;
  final bool isStationary;
  final bool isPassengerMode;

  const DigitalMeterDisplay({
    super.key,
    required this.totalFare,
    required this.distanceKm,
    required this.waitingSeconds,
    required this.tripDurationSeconds,
    required this.speedKmh,
    required this.isStationary,
    this.isPassengerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.meterColors;
    final fareColor = isPassengerMode ? AppColors.passengerDigit : colors.meterAmber;
    final fareGlow = isPassengerMode ? Colors.transparent : colors.meterAmberGlow;
    final bgBoxColor = isPassengerMode ? const Color(0xFF000000) : colors.surface;
    final borderColor = isPassengerMode ? const Color(0xFF333333) : colors.cardBorder;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isPassengerMode ? 24 : 20,
        vertical: isPassengerMode ? 32 : 24,
      ),
      decoration: BoxDecoration(
        color: bgBoxColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isPassengerMode ? 2 : 1.2),
        boxShadow: isPassengerMode
            ? []
            : [
                BoxShadow(
                  color: fareGlow,
                  blurRadius: 24,
                  spreadRadius: -6,
                )
              ],
      ),
      child: Column(
        children: [
          // FARE HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isStationary ? colors.meterAmber : colors.meterGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPassengerMode ? 'TOTAL FARE' : 'AUTO FARE METER',
                    style: TextStyle(
                      color: isPassengerMode ? AppColors.passengerLabel : colors.textSecondary,
                      fontSize: isPassengerMode ? 14 : 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isStationary ? colors.meterAmber : colors.meterGreen).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isStationary ? colors.meterAmber : colors.meterGreen).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  isStationary ? 'WAITING' : 'MOVING',
                  style: TextStyle(
                    color: isStationary ? colors.meterAmber : colors.meterGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GIANT DIGITAL FARE DIGITS
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.formatCurrency(totalFare),
              style: TextStyle(
                color: fareColor,
                fontSize: isPassengerMode ? 92 : 72,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // STATS TILES (Distance, Waiting, Trip Time)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: isPassengerMode ? const Color(0xFF111111) : colors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPassengerMode ? const Color(0xFF262626) : colors.divider,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  label: 'DISTANCE',
                  value: '${distanceKm.toStringAsFixed(2)} km',
                  isPassenger: isPassengerMode,
                  accentColor: colors.meterCyan,
                  colors: colors,
                ),
                _buildDivider(isPassengerMode, colors),
                _buildStatColumn(
                  label: 'WAITING',
                  value: Formatters.formatDuration(waitingSeconds),
                  isPassenger: isPassengerMode,
                  accentColor: colors.meterAmber,
                  colors: colors,
                ),
                _buildDivider(isPassengerMode, colors),
                _buildStatColumn(
                  label: 'TRIP TIME',
                  value: Formatters.formatDuration(tripDurationSeconds),
                  isPassenger: isPassengerMode,
                  accentColor: colors.textPrimary,
                  colors: colors,
                ),
              ],
            ),
          ),

          if (!isPassengerMode) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed_rounded, size: 16, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Speed: ${speedKmh.toStringAsFixed(1)} km/h',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required bool isPassenger,
    required Color accentColor,
    required MeterThemeColors colors,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isPassenger ? AppColors.passengerLabel : colors.textMuted,
            fontSize: isPassenger ? 12 : 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isPassenger ? AppColors.passengerWhite : accentColor,
            fontSize: isPassenger ? 22 : 18,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isPassenger, MeterThemeColors colors) {
    return Container(
      height: 36,
      width: 1,
      color: isPassenger ? const Color(0xFF333333) : colors.divider,
    );
  }
}
