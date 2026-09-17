import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
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
    final colors = context.meterColors;

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
                decoration: BoxDecoration(
                  color: colors.meterGreen,
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
                    color: colors.meterAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.meterAmber, width: 0.8),
                  ),
                  child: Text(
                    'DEMO',
                    style: TextStyle(
                      color: colors.meterAmber,
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
              icon: Icon(Icons.tv_rounded, color: colors.meterCyan),
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
                icon: Icon(Icons.tune_rounded, color: colors.meterAmber),
                tooltip: 'Jury Demo Controls',
                onPressed: () => _openDemoControls(context),
              ),
            // Minimize to Dashboard
            IconButton(
              icon: Icon(Icons.dashboard_customize_outlined, color: colors.textSecondary),
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
                            color: colors.meterAmber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.meterAmber.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.satellite_alt_rounded, size: 16, color: colors.meterAmber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'GPS signal weak — auto noise-filter active',
                                  style: TextStyle(color: colors.meterAmber, fontSize: 11, fontWeight: FontWeight.bold),
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
                          color: colors.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.divider),
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(Icons.navigation_rounded, color: colors.meterCyan, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _showDestination ? 'Trip Destination' : 'Optional Passenger Destination & ETA',
                                            style: TextStyle(
                                              color: colors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (!_showDestination)
                                            Text(
                                              'Tap to enter destination for passenger fare & ETA visibility',
                                              style: TextStyle(color: colors.textMuted, fontSize: 11),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      _showDestination ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showDestination) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _destinationController,
                                      style: TextStyle(color: colors.textPrimary, fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText: 'Enter drop destination',
                                        prefixIcon: Icon(Icons.location_on_rounded, color: colors.meterCyan, size: 18),
                                        filled: true,
                                        fillColor: colors.surface,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: colors.cardBorder),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: colors.cardBorder),
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
                                        Icon(Icons.access_time_rounded, size: 14, color: colors.meterGreen),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Est. Arrival: $_estimatedEta',
                                          style: TextStyle(
                                            color: colors.meterGreen,
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
                              style: TextStyle(
                                color: colors.meterAmber,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showBreakdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: colors.meterAmber,
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
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.cardBorder)),
                ),
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.meterRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: colors.meterRed.withOpacity(0.4),
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
