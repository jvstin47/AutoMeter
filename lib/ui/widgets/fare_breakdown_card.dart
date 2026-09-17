import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/fare_engine.dart';

class FareBreakdownCard extends StatelessWidget {
  final FareBreakdown breakdown;
  final String currency;

  const FareBreakdownCard({
    super.key,
    required this.breakdown,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.meterSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.meterCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FARE BREAKDOWN',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.meterCard,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'TARIFF V1',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Base Fare Row
          _buildItemRow(
            label: 'Base Minimum Fare',
            detail: 'Initial charge',
            amount: breakdown.baseFare,
          ),
          const SizedBox(height: 12),

          // Distance Charge Row
          _buildItemRow(
            label: 'Distance Charge',
            detail: breakdown.chargeableDistanceKm < breakdown.distanceKm
                ? '${breakdown.chargeableDistanceKm.toStringAsFixed(2)} km (above base) × ${Formatters.formatCurrency(breakdown.perKmRate, symbol: currency)}/km'
                : '${breakdown.distanceKm.toStringAsFixed(2)} km × ${Formatters.formatCurrency(breakdown.perKmRate, symbol: currency)}/km',
            amount: breakdown.distanceFare,
          ),
          const SizedBox(height: 12),

          // Waiting Charge Row
          _buildItemRow(
            label: 'Waiting Charge',
            detail: '${breakdown.waitingMinutes} min (${Formatters.formatDuration(breakdown.waitingDurationSeconds)}) × ${Formatters.formatCurrency(breakdown.waitingRatePerMin, symbol: currency)}/min',
            amount: breakdown.waitingFare,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.meterCardBorder, thickness: 1.5),
          ),

          // Total Fare Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'TOTAL FARE',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                Formatters.formatCurrency(breakdown.totalFare, symbol: currency),
                style: const TextStyle(
                  color: AppColors.meterAmber,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow({
    required String label,
    required String detail,
    required double amount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          Formatters.formatCurrency(amount, symbol: currency),
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
