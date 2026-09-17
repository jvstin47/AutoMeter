import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/trip_manager.dart';
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
        backgroundColor: AppColors.meterSurface,
        indicatorColor: AppColors.meterAmber.withOpacity(0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.speed_rounded),
            selectedIcon: Icon(Icons.speed_rounded, color: AppColors.meterAmber),
            label: 'Meter',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_rounded, color: AppColors.meterAmber),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_rupee_rounded),
            selectedIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.meterAmber),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.meterAmber),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, TripManager manager, bool isTripActive) {
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ready Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isTripActive
                  ? AppColors.meterGreen.withOpacity(0.12)
                  : AppColors.meterCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTripActive ? AppColors.meterGreen : AppColors.meterCardBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isTripActive ? AppColors.meterGreen : AppColors.meterAmber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTripActive ? 'TRIP IN PROGRESS' : 'YOUR METER IS READY',
                    style: TextStyle(
                      color: isTripActive ? AppColors.meterGreen : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  Formatters.formatDate(now),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (manager.wasRestoredFromCrash) ...[
            const SizedBox(height: 12),
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
          const SizedBox(height: 24),

          // Primary START TRIP (or RETURN TO TRIP) Action
          if (isTripActive) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.meterSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.meterGreen, width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CURRENT LIVE FARE',
                        style: TextStyle(
                          color: AppColors.textSecondary,
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
                      color: AppColors.meterGreen,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.meterGreen,
                        foregroundColor: Colors.black,
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Giant Start Trip Button
            SizedBox(
              height: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.meterAmber,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: AppColors.meterAmber.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isStarting
                    ? null
                    : () async {
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: _isStarting
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.meterAmber),
                            )
                          : const Icon(Icons.play_arrow_rounded, color: AppColors.meterAmber, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'START TRIP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Tap to begin live fare tracking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 28),

          // TODAY'S OVERVIEW METRICS
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
                child: _buildMetricCard(
                  title: "TODAY'S EARNINGS",
                  value: Formatters.formatCurrency(manager.todayEarnings),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.meterAmber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'COMPLETED TRIPS',
                  value: '${manager.todayTripCount}',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.meterGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'DISTANCE COVERED',
                  value: '${manager.todayDistanceKm.toStringAsFixed(1)} km',
                  icon: Icons.route_rounded,
                  color: AppColors.meterCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'WAITING TIME',
                  value: '${manager.todayWaitingMinutes} min',
                  icon: Icons.hourglass_bottom_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // TARIFF SUMMARY CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.meterCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.meterCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TARIFF CONFIG',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Driver: ${manager.driverProfile.name}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTariffPill('BASE', Formatters.formatCurrency(manager.fareConfig.baseFare)),
                    _buildTariffPill('PER KM', '${Formatters.formatCurrency(manager.fareConfig.perKmRate)}/km'),
                    _buildTariffPill('WAITING', '${Formatters.formatCurrency(manager.fareConfig.waitingRatePerMin)}/min'),
                  ],
                ),
              ],
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.meterSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.meterCardBorder),
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
            style: const TextStyle(
              color: AppColors.textMuted,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.meterSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.meterDivider),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
