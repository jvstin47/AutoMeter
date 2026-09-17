import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/demo_simulation_service.dart';
import '../../services/trip_manager.dart';

class DemoControlsSheet extends StatelessWidget {
  const DemoControlsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final demoService = manager.demoService;
    final isStoppedAtSignal = demoService.state == DemoVehicleState.waitingAtSignal;
    final speedMultiplier = demoService.speedMultiplier;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.meterSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.meterAmber.withOpacity(0.4), width: 1.5),
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
                      color: AppColors.meterAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.meterAmber, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'JURY DEMO CONTROLS',
                    style: TextStyle(
                      color: AppColors.meterAmber,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Use these controls to demonstrate distance accumulation and waiting-time tariff increases indoors to the competition jury.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // 1. Vehicle Movement Toggle
          const Text(
            'SIMULATE TRAFFIC / SIGNAL',
            style: TextStyle(
              color: AppColors.textMuted,
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isStoppedAtSignal
                    ? AppColors.meterRed.withOpacity(0.15)
                    : AppColors.meterGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isStoppedAtSignal ? AppColors.meterRed : AppColors.meterGreen,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isStoppedAtSignal ? Icons.traffic_rounded : Icons.directions_car_rounded,
                    color: isStoppedAtSignal ? AppColors.meterRed : AppColors.meterGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isStoppedAtSignal ? 'Vehicle Stopped at Signal' : 'Vehicle Driving (~30 km/h)',
                          style: TextStyle(
                            color: isStoppedAtSignal ? AppColors.meterRed : AppColors.meterGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isStoppedAtSignal
                              ? 'Waiting timer is actively ticking fare'
                              : 'Distance is actively ticking fare',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isStoppedAtSignal ? AppColors.meterRed : AppColors.meterGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isStoppedAtSignal ? 'RESUME' : 'STOP',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 2. Speed Warp Multiplier
          const Text(
            'DEMO TIME ACCELERATION (WARP)',
            style: TextStyle(
              color: AppColors.textMuted,
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
                      backgroundColor: isSelected ? AppColors.meterAmber : AppColors.meterCard,
                      foregroundColor: isSelected ? Colors.black : AppColors.textPrimary,
                      side: BorderSide(
                        color: isSelected ? AppColors.meterAmber : AppColors.meterCardBorder,
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
