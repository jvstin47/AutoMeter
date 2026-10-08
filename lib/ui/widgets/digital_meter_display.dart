import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../core/utils/formatters.dart';

/// "Digital Industrial" Glanceable Fare Meter HUD
/// Combines 1px hardware borders, subtle status glows, and 200ms glanceability.
class DigitalMeterDisplay extends StatefulWidget {
  final double totalFare;
  final double distanceKm;
  final int waitingSeconds;
  final int tripDurationSeconds;
  final double speedKmh;
  final bool isStationary;
  final double waitingRatePerMin;
  final bool isPassengerMode;

  const DigitalMeterDisplay({
    super.key,
    required this.totalFare,
    required this.distanceKm,
    required this.waitingSeconds,
    required this.tripDurationSeconds,
    required this.speedKmh,
    required this.isStationary,
    this.waitingRatePerMin = 1.50,
    this.isPassengerMode = false,
  });

  @override
  State<DigitalMeterDisplay> createState() => _DigitalMeterDisplayState();
}

class _DigitalMeterDisplayState extends State<DigitalMeterDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // 60 bpm subtle pulse for peripheral vision awareness
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.meterColors;

    final Color statusColor = widget.isStationary
        ? const Color(0xFFFF5252) // Signal Crimson
        : const Color(0xFF00E676); // Digital Emerald

    final Color fareColor = widget.isPassengerMode
        ? AppColors.passengerDigit
        : colors.meterAmber;

    final Color bgBoxColor = widget.isPassengerMode
        ? const Color(0xFF000000)
        : colors.surface;

    final Color innerBorder = widget.isPassengerMode
        ? const Color(0xFF333333)
        : colors.cardBorder;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isPassengerMode ? 24 : 20,
            vertical: widget.isPassengerMode ? 32 : 24,
          ),
          decoration: BoxDecoration(
            color: bgBoxColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: innerBorder,
              width: widget.isPassengerMode ? 2 : 1.2,
            ),
            boxShadow: widget.isPassengerMode
                ? []
                : [
                    // Dynamic Peripheral Status Glow
                    BoxShadow(
                      color: statusColor.withOpacity(
                        widget.isStationary ? _glowAnimation.value * 0.35 : 0.15,
                      ),
                      blurRadius: widget.isStationary ? 28 : 20,
                      spreadRadius: widget.isStationary ? 2 : -2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.08),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER: Hardware Meter Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isPassengerMode ? 'TOTAL REGULATED FARE' : 'AUTO FARE METER • V1',
                        style: TextStyle(
                          color: widget.isPassengerMode ? AppColors.passengerLabel : colors.textSecondary,
                          fontSize: widget.isPassengerMode ? 14 : 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  if (!widget.isPassengerMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141824),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E2538), width: 1),
                      ),
                      child: Text(
                        '${widget.speedKmh.toStringAsFixed(1)} KM/H',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF2979FF), // Telemetry Cobalt
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // THE BIG NUMBER: 72pt / 92pt Monospaced Tabular Figures
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  Formatters.formatCurrency(widget.totalFare),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: fareColor,
                    fontSize: widget.isPassengerMode ? 92 : 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: [
                      Shadow(
                        color: fareColor.withOpacity(0.35),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // DYNAMIC MOTION STATUS BADGE
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(widget.isStationary ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: statusColor.withOpacity(widget.isStationary ? 0.8 : 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isStationary ? Icons.pause_circle_filled_rounded : Icons.navigation_rounded,
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isStationary
                          ? 'STATIONARY • WAITING CHARGES ACCRUING (+₹${widget.waitingRatePerMin.toStringAsFixed(2)}/M)'
                          : 'VEHICLE IN MOTION • DISTANCE TRACKING ACTIVE',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // TELEMETRY GRID: Distance, Waiting Time, Trip Time
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: widget.isPassengerMode ? const Color(0xFF111111) : colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isPassengerMode ? const Color(0xFF262626) : colors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      label: 'DISTANCE',
                      value: '${widget.distanceKm.toStringAsFixed(2)} km',
                      isPassenger: widget.isPassengerMode,
                      accentColor: const Color(0xFF2979FF), // Telemetry Cobalt
                      icon: Icons.straighten_rounded,
                      colors: colors,
                    ),
                    _buildDivider(widget.isPassengerMode, colors),
                    _buildStatColumn(
                      label: 'WAITING',
                      value: Formatters.formatDuration(widget.waitingSeconds),
                      isPassenger: widget.isPassengerMode,
                      accentColor: widget.isStationary
                          ? const Color(0xFFFF5252)
                          : const Color(0xFFFFB300),
                      icon: Icons.access_time_filled_rounded,
                      colors: colors,
                    ),
                    _buildDivider(widget.isPassengerMode, colors),
                    _buildStatColumn(
                      label: 'TRIP TIME',
                      value: Formatters.formatDuration(widget.tripDurationSeconds),
                      isPassenger: widget.isPassengerMode,
                      accentColor: colors.textPrimary,
                      icon: Icons.timelapse_rounded,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required bool isPassenger,
    required Color accentColor,
    required IconData icon,
    required MeterThemeColors colors,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: isPassenger ? AppColors.passengerLabel : colors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isPassenger ? AppColors.passengerLabel : colors.textMuted,
                fontSize: isPassenger ? 12 : 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isPassenger ? AppColors.passengerWhite : accentColor,
            fontSize: isPassenger ? 22 : 18,
            fontWeight: FontWeight.w900,
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
