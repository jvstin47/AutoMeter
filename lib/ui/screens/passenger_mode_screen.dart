import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/trip_manager.dart';
import '../widgets/digital_meter_display.dart';

class PassengerModeScreen extends StatelessWidget {
  const PassengerModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final isTripActive = manager.state == TripState.active;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Exiting passenger view preserves active trip completely
      },
      child: Scaffold(
        backgroundColor: AppColors.passengerBg,
        body: SafeArea(
          child: Column(
            children: [
            // Top Bar: High-contrast auto rickshaw vehicle indicator & driver return button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF444444)),
                        ),
                        child: Text(
                          manager.driverProfile.vehicleNumber,
                          style: const TextStyle(
                            color: AppColors.passengerWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isTripActive ? AppColors.meterGreen : AppColors.meterAmber).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isTripActive ? 'METER ACTIVE' : 'METER STANDBY',
                          style: TextStyle(
                            color: isTripActive ? AppColors.meterGreen : AppColors.meterAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Discreet Exit Button for Driver
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF383838)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen_exit_rounded, size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'DRIVER EXIT',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Passenger Display Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DigitalMeterDisplay(
                        totalFare: manager.currentBreakdown.totalFare,
                        distanceKm: manager.distanceKm,
                        waitingSeconds: manager.waitingDurationSeconds,
                        tripDurationSeconds: manager.tripDurationSeconds,
                        speedKmh: manager.currentSpeedKmh,
                        isStationary: manager.isStationary,
                        isPassengerMode: true,
                      ),
                      const SizedBox(height: 32),

                      // Passenger Trust Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2B2B2B)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.meterGreen),
                            const SizedBox(width: 10),
                            Text(
                              'GOVT. APPROVED DIGITAL TARIFF • UPI ENABLED',
                              style: TextStyle(
                                color: AppColors.passengerLabel.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Driver Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Driver: ${manager.driverProfile.name} • Pay via QR at trip completion',
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
