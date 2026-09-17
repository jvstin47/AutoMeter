import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/trip_manager.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final trips = manager.trips;

    final totalEarnings = trips
        .where((t) => t.paymentStatus == 'confirmed')
        .fold(0.0, (sum, t) => sum + t.totalFare);

    final upiEarnings = trips
        .where((t) => t.paymentStatus == 'confirmed' && t.paymentMethod == 'upi')
        .fold(0.0, (sum, t) => sum + t.totalFare);

    final cashEarnings = trips
        .where((t) => t.paymentStatus == 'confirmed' && t.paymentMethod == 'cash')
        .fold(0.0, (sum, t) => sum + t.totalFare);

    final totalDistance = trips.fold(0.0, (sum, t) => sum + t.distanceKm);
    final totalWaitingSeconds = trips.fold(0, (sum, t) => sum + t.waitingDurationSeconds);
    final totalWaitingMin = (totalWaitingSeconds / 60).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today's Big Earnings Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.meterSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.meterAmber.withOpacity(0.4), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.meterAmberGlow,
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TODAY'S EARNINGS",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(Icons.trending_up_rounded, color: AppColors.meterGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.formatCurrency(manager.todayEarnings, symbol: manager.fareConfig.currency),
                  style: const TextStyle(
                    color: AppColors.meterAmber,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${manager.todayTripCount} trips completed today',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Key Metrics Grid
          const Text(
            "TODAY'S METER STATS",
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
                child: _buildMetricTile(
                  label: 'TOTAL DISTANCE',
                  value: '${manager.todayDistanceKm.toStringAsFixed(1)} km',
                  icon: Icons.route_rounded,
                  color: AppColors.meterCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  label: 'WAITING TIME',
                  value: '${manager.todayWaitingMinutes} min',
                  icon: Icons.hourglass_bottom_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // All Time Performance & Payment Method Split
          const Text(
            'HISTORICAL TOTALS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.meterCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.meterCardBorder),
            ),
            child: Column(
              children: [
                _buildStatRow('All-Time Revenue', Formatters.formatCurrency(totalEarnings, symbol: manager.fareConfig.currency)),
                const Divider(color: AppColors.meterDivider, height: 24),
                _buildStatRow('Total Trips Recorded', '${trips.length}'),
                const Divider(color: AppColors.meterDivider, height: 24),
                _buildStatRow('Total Distance Logged', '${totalDistance.toStringAsFixed(1)} km'),
                const Divider(color: AppColors.meterDivider, height: 24),
                _buildStatRow('Total Waiting Logged', '$totalWaitingMin min'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Split (UPI vs Cash)
          const Text(
            'PAYMENT COLLECTION SPLIT',
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
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.meterSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.meterGreen.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 16, color: AppColors.meterGreen),
                          SizedBox(width: 6),
                          Text(
                            'UPI QR',
                            style: TextStyle(
                              color: AppColors.meterGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(upiEarnings, symbol: manager.fareConfig.currency),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.meterSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.meterAmber.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payments_rounded, size: 16, color: AppColors.meterAmber),
                          SizedBox(width: 6),
                          Text(
                            'CASH',
                            style: TextStyle(
                              color: AppColors.meterAmber,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(cashEarnings, symbol: manager.fareConfig.currency),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.meterCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.meterCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
