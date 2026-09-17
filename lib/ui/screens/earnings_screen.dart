import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/trip_manager.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final colors = context.meterColors;
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
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.meterAmber.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: colors.meterAmberGlow,
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TODAY'S EARNINGS",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Icon(Icons.trending_up_rounded, color: colors.meterGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.formatCurrency(manager.todayEarnings, symbol: manager.fareConfig.currency),
                  style: TextStyle(
                    color: colors.meterAmber,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${manager.todayTripCount} trips completed today',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Key Metrics Grid
          Text(
            "TODAY'S METER STATS",
            style: TextStyle(
              color: colors.textSecondary,
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
                  color: colors.meterCyan,
                  colors: colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  label: 'WAITING TIME',
                  value: '${manager.todayWaitingMinutes} min',
                  icon: Icons.hourglass_bottom_rounded,
                  color: colors.textSecondary,
                  colors: colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // All Time Performance & Payment Method Split
          Text(
            'HISTORICAL TOTALS',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              children: [
                _buildStatRow('All-Time Revenue', Formatters.formatCurrency(totalEarnings, symbol: manager.fareConfig.currency), colors),
                Divider(color: colors.divider, height: 24),
                _buildStatRow('Total Trips Recorded', '${trips.length}', colors),
                Divider(color: colors.divider, height: 24),
                _buildStatRow('Total Distance Logged', '${totalDistance.toStringAsFixed(1)} km', colors),
                Divider(color: colors.divider, height: 24),
                _buildStatRow('Total Waiting Logged', '$totalWaitingMin min', colors),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment Split (UPI vs Cash)
          Text(
            'PAYMENT COLLECTION SPLIT',
            style: TextStyle(
              color: colors.textSecondary,
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
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.meterGreen.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, color: colors.meterGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'UPI ONLINE',
                            style: TextStyle(color: colors.meterGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(upiEarnings, symbol: manager.fareConfig.currency),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalEarnings > 0 ? '${((upiEarnings / totalEarnings) * 100).toStringAsFixed(0)}% of total' : '0% of total',
                        style: TextStyle(color: colors.textMuted, fontSize: 11),
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
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.meterAmber.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.money_rounded, color: colors.meterAmber, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'CASH',
                            style: TextStyle(color: colors.meterAmber, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Formatters.formatCurrency(cashEarnings, symbol: manager.fareConfig.currency),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalEarnings > 0 ? '${((cashEarnings / totalEarnings) * 100).toStringAsFixed(0)}% of total' : '0% of total',
                        style: TextStyle(color: colors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required MeterThemeColors colors,
  }) {
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
            label,
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, MeterThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
