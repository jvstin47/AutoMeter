import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/theme_provider.dart';
import '../../services/trip_manager.dart';
import '../widgets/revenue_tile.dart';
import '../widgets/weather_battery_pill.dart';
import 'earnings_screen.dart';
import 'live_meter_screen.dart';
import 'passenger_mode_screen.dart';
import 'settings_screen.dart';
import 'trip_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final colors = context.meterColors;

    // If trip is currently active and user is on dashboard, show active banner or button to return
    final isTripActive = manager.state == TripState.active;

    final pages = [
      _buildDashboardContent(context, manager, isTripActive),
      const TripHistoryScreen(),
      const EarningsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.meterAmber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.electric_rickshaw, color: AppColors.meterAmber, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AUTOMETER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  manager.driverProfile.vehicleNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Demo Mode Badge / Toggle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: InkWell(
              onTap: () {
                manager.setDemoMode(!manager.isDemoMode);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: manager.isDemoMode
                      ? AppColors.meterAmber.withOpacity(0.2)
                      : AppColors.meterCardBorder,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: manager.isDemoMode ? AppColors.meterAmber : AppColors.textMuted,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      manager.isDemoMode ? Icons.science_rounded : Icons.gps_fixed_rounded,
                      size: 13,
                      color: manager.isDemoMode ? AppColors.meterAmber : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      manager.isDemoMode ? 'DEMO' : 'GPS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: manager.isDemoMode ? AppColors.meterAmber : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Weather + Battery Device Health Pill
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: WeatherBatteryPill(),
          ),
          Consumer<ThemeProvider>(
            builder: (context, tp, _) => IconButton(
              icon: Icon(tp.currentMode.icon, color: colors.meterAmber),
              tooltip: 'Switch Theme (${tp.currentMode.label})',
              onPressed: () => tp.cycleTheme(),
            ),
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        backgroundColor: colors.surface,
        indicatorColor: colors.meterAmber.withOpacity(0.25),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.speed_rounded),
            selectedIcon: Icon(Icons.speed_rounded, color: colors.meterAmber),
            label: 'Meter',
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: colors.meterAmber),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: const Icon(Icons.currency_rupee_rounded),
            selectedIcon: Icon(Icons.currency_rupee_rounded, color: colors.meterAmber),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_rounded),
            selectedIcon: Icon(Icons.settings_rounded, color: colors.meterAmber),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TripManager manager, bool isTripActive) {
    final now = DateTime.now();
    final colors = context.meterColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. SYSTEM STATUS BANNER (Pulsing Emerald Glow)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isTripActive ? colors.meterAmber : const Color(0xFF00E676)).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isTripActive ? colors.meterAmber : const Color(0xFF00E676)).withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isTripActive ? colors.meterAmber : const Color(0xFF00E676)).withOpacity(0.15),
                  blurRadius: 18,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isTripActive ? Icons.electric_rickshaw_rounded : Icons.verified_user_rounded,
                  color: isTripActive ? colors.meterAmber : const Color(0xFF00E676),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTripActive ? "TRIP ACTIVE • TRACKING TELEMETRY" : "YOUR METER IS READY",
                        style: TextStyle(
                          color: isTripActive ? colors.meterAmber : const Color(0xFF00E676),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "GPS LOCKED • Vehicle: ${manager.driverProfile.vehicleNumber}",
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatDate(now),
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (manager.wasRestoredFromCrash) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.meterAmber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.meterAmber.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restore_rounded, color: AppColors.meterAmber, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Trip state recovered from previous session. Tap below to return to meter.',
                      style: TextStyle(color: AppColors.meterAmber, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                    onPressed: () => manager.acknowledgeCrashRecovery(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),

          // 2. THE "POCKET" VIEW: INDUSTRIAL REVENUE & TRIP TILES
          const Text(
            "TODAY'S OVERVIEW",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RevenueTile(
                  label: "TODAY'S REVENUE",
                  value: Formatters.formatCurrency(manager.todayEarnings),
                  isCurrency: true,
                  icon: Icons.currency_rupee_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: RevenueTile(
                  label: "COMPLETED TRIPS",
                  value: '${manager.todayTripCount}',
                  isCurrency: false,
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3. TARIFF TRANSPARENCY CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "ACTIVE TARIFF CONFIGURATION",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      "Driver: ${manager.driverProfile.name}",
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Base: ${Formatters.formatCurrency(manager.fareConfig.baseFare)} (${manager.fareConfig.minDistanceKm} km) | Rate: ${Formatters.formatCurrency(manager.fareConfig.perKmRate)}/km | Wait: ${Formatters.formatCurrency(manager.fareConfig.waitingRatePerMin)}/m",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. THE BIG TACTILE START TRIP (OR RETURN TO TRIP) SLAB
          if (isTripActive) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.meterGreen, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT LIVE FARE',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        Formatters.formatDuration(manager.tripDurationSeconds),
                        style: const TextStyle(
                          color: AppColors.meterCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(manager.currentBreakdown.totalFare),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.meterGreen,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.meterGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LiveMeterScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'RETURN TO ACTIVE METER',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Giant Tactile Start Trip Slab
            Container(
              width: double.infinity,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _isStarting
                      ? null
                      : () async {
                          await HapticFeedback.heavyImpact();
                          setState(() => _isStarting = true);
                          try {
                            await manager.startTrip();
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LiveMeterScreen()),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isStarting = false);
                            }
                          }
                        },
                  child: Center(
                    child: _isStarting
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_fill_rounded, color: Colors.black, size: 28),
                              SizedBox(width: 12),
                              Text(
                                "START TRIP",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'DISTANCE COVERED',
                  value: '${manager.todayDistanceKm.toStringAsFixed(1)} km',
                  icon: Icons.route_rounded,
                  color: const Color(0xFF2979FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'WAITING TIME',
                  value: '${manager.todayWaitingMinutes} min',
                  icon: Icons.hourglass_bottom_rounded,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Passenger Mode Quick Access Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.meterCyan, width: 1.2),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PassengerModeScreen()),
              );
            },
            icon: const Icon(Icons.tv_rounded, color: AppColors.meterCyan),
            label: const Text(
              'OPEN PASSENGER-FACING DISPLAY',
              style: TextStyle(
                color: AppColors.meterCyan,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colors = context.meterColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: color),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTariffPill(String label, String value) {
    final colors = context.meterColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
