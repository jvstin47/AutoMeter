import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/trip_manager.dart';
import '../widgets/demo_controls_sheet.dart';
import '../widgets/digital_meter_display.dart';
import '../widgets/fare_breakdown_card.dart';
import 'passenger_mode_screen.dart';
import 'payment_qr_screen.dart';

class LiveMeterScreen extends StatefulWidget {
  const LiveMeterScreen({super.key});

  @override
  State<LiveMeterScreen> createState() => _LiveMeterScreenState();
}

class _LiveMeterScreenState extends State<LiveMeterScreen> {
  bool _showBreakdown = false;
  bool _showDestination = false;
  bool _isStopping = false;
  final TextEditingController _destinationController = TextEditingController(text: 'Indiranagar 100ft Rd');
  String _estimatedEta = '14 min (4.2 km)';

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _openDemoControls(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DemoControlsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();

    return PopScope(
      canPop: false, // Prevent accidental back button dismissal of active trip
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Return to dashboard without stopping active trip
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.meterGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE METER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              if (manager.isDemoMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.meterAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.meterAmber, width: 0.8),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: AppColors.meterAmber,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            // Passenger Mode Shortcut
            IconButton(
              icon: const Icon(Icons.tv_rounded, color: AppColors.meterCyan),
              tooltip: 'Passenger Display Mode',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PassengerModeScreen()),
                );
              },
            ),
            // Jury Demo Sheet Trigger
            if (manager.isDemoMode)
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.meterAmber),
                tooltip: 'Jury Demo Controls',
                onPressed: () => _openDemoControls(context),
              ),
            // Minimize to Dashboard
            IconButton(
              icon: const Icon(Icons.dashboard_customize_outlined, color: AppColors.textSecondary),
              tooltip: 'Dashboard View',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!manager.isDemoMode && manager.isGpsSignalWeak) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.meterAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.meterAmber.withOpacity(0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.satellite_alt_rounded, size: 16, color: AppColors.meterAmber),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'GPS signal weak — auto noise-filter active',
                                  style: TextStyle(color: AppColors.meterAmber, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // DIGITAL METER DISPLAY (Huge Fare + Stats)
                      DigitalMeterDisplay(
                        totalFare: manager.currentBreakdown.totalFare,
                        distanceKm: manager.distanceKm,
                        waitingSeconds: manager.waitingDurationSeconds,
                        tripDurationSeconds: manager.tripDurationSeconds,
                        speedKmh: manager.currentSpeedKmh,
                        isStationary: manager.isStationary,
                        isPassengerMode: false,
                      ),
                      const SizedBox(height: 16),

                      // Optional Destination & ETA Card (Section 13 Secondary Feature)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.meterCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.meterDivider),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showDestination = !_showDestination;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    const Icon(Icons.navigation_rounded, size: 16, color: AppColors.meterCyan),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _showDestination ? 'Destination & Route' : 'Destination: ${_destinationController.text}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      _showDestination ? Icons.expand_less : Icons.expand_more,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showDestination) ...[
                              const Divider(height: 1, color: AppColors.meterDivider),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: _destinationController,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Enter destination...',
                                        hintStyle: const TextStyle(color: AppColors.textMuted),
                                        prefixIcon: const Icon(Icons.place_rounded, color: AppColors.meterAmber, size: 18),
                                        filled: true,
                                        fillColor: AppColors.meterSurface,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: AppColors.meterCardBorder),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _estimatedEta = '12 min (3.8 km)';
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.meterGreen),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Est. Arrival: $_estimatedEta',
                                          style: const TextStyle(
                                            color: AppColors.meterGreen,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Live Tariff Breakdown
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showBreakdown = !_showBreakdown;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showBreakdown ? 'Hide Fare Breakdown' : 'View Live Fare Breakdown',
                              style: const TextStyle(
                                color: AppColors.meterAmber,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showBreakdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.meterAmber,
                              size: 18,
                            ),
                          ],
                        ),
                      ),

                      if (_showBreakdown) ...[
                        const SizedBox(height: 12),
                        FareBreakdownCard(
                          breakdown: manager.currentBreakdown,
                          currency: manager.fareConfig.currency,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // BOTTOM ACTION BAR: Large STOP TRIP Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.meterSurface,
                  border: Border(top: BorderSide(color: AppColors.meterCardBorder)),
                ),
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.meterRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.meterRed.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isStopping
                        ? null
                        : () async {
                            setState(() {
                              _isStopping = true;
                            });
                            final completedTrip = await manager.stopTrip();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentQrScreen(trip: completedTrip),
                                ),
                              );
                            }
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isStopping
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.stop_rounded, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          _isStopping ? 'CALCULATING FINAL FARE...' : 'STOP TRIP & GENERATE FARE',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
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
