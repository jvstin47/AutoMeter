import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../services/demo_simulation_service.dart';
import '../../services/trip_manager.dart';

class DemoControlsSheet extends StatelessWidget {
  const DemoControlsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final demoService = manager.demoService;
    final colors = context.meterColors;

    final isStoppedAtSignal = demoService.state == DemoVehicleState.waitingAtSignal;
    final speedMultiplier = demoService.speedMultiplier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: colors.meterAmber.withOpacity(0.4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.meterAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.tune_rounded, color: colors.meterAmber, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'JURY DEMO CONTROLS',
                    style: TextStyle(
                      color: colors.meterAmber,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use these rapid controls during presentations to simulate realistic city conditions without driving:',
            style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 20),

          // 1. Traffic Signal / Waiting Time Simulation Toggle
          Text(
            'SIGNAL STOP / WAITING CHARGE ACCUMULATION',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              manager.toggleDemoTrafficStop();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isStoppedAtSignal
                    ? colors.meterRed.withOpacity(0.15)
                    : colors.meterGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isStoppedAtSignal ? colors.meterRed : colors.meterGreen,
                  width: 1.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isStoppedAtSignal ? colors.meterRed : colors.meterGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isStoppedAtSignal ? Icons.traffic_rounded : Icons.directions_bike_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isStoppedAtSignal ? 'AUTO STOPPED AT TRAFFIC SIGNAL' : 'AUTO MOVING ON ROAD',
                          style: TextStyle(
                            color: isStoppedAtSignal ? colors.meterRed : colors.meterGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isStoppedAtSignal
                            ? 'Speed drops to 0 km/h • Waiting fee accumulating'
                            : 'Vehicle moving (~24 km/h) • Distance accumulating',
                          style: TextStyle(
                            color: colors.textSecondary.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isStoppedAtSignal ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: isStoppedAtSignal ? colors.meterRed : colors.meterGreen,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Speed Warp Multiplier
          Text(
            'DEMO TIME ACCELERATION (WARP)',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [1.0, 3.0, 5.0, 10.0].map((mult) {
              final isSelected = (speedMultiplier - mult).abs() < 0.1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? colors.meterAmber : colors.card,
                      foregroundColor: isSelected ? Colors.black : colors.textPrimary,
                      side: BorderSide(
                        color: isSelected ? colors.meterAmber : colors.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      manager.setDemoSpeedMultiplier(mult);
                    },
                    child: Text(
                      '${mult.toInt()}x',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
