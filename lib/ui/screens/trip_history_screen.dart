import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/trip_model.dart';
import '../../services/fare_engine.dart';
import '../../services/trip_manager.dart';
import '../widgets/fare_breakdown_card.dart';
import 'payment_qr_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final trips = manager.trips;

    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.meterSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.meterCardBorder),
                ),
                child: const Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Completed Trips Yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start a trip on the dashboard to calculate fares and record history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final isToday = Formatters.formatDate(trip.startTime) == 'Today';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showTripDetailsModal(context, trip, manager),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date & Time Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: isToday ? AppColors.meterAmber : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${Formatters.formatDate(trip.startTime)} • ${Formatters.formatTime(trip.startTime)}',
                            style: TextStyle(
                              color: isToday ? AppColors.meterAmber : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.formatCurrency(trip.totalFare, symbol: manager.fareConfig.currency),
                        style: const TextStyle(
                          color: AppColors.meterAmber,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Distance & Duration
                  Text(
                    '${trip.distanceKm.toStringAsFixed(2)} km · ${Formatters.formatDurationHuman(trip.tripDurationSeconds)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Status Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildPaymentBadge(trip.paymentMethod, trip.paymentStatus),
                          if (trip.isDemo) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.meterSurface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.meterCardBorder),
                              ),
                              child: const Text(
                                'DEMO',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentBadge(String method, String status) {
    final isPaid = status == 'confirmed';
    final isUpi = method == 'upi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isPaid ? AppColors.meterGreen : AppColors.meterAmber).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isPaid ? AppColors.meterGreen : AppColors.meterAmber).withOpacity(0.4),
        ),
      ),
      child: Text(
        '${isUpi ? 'UPI' : 'Cash'} • ${isPaid ? 'Paid' : 'Pending'}',
        style: TextStyle(
          color: isPaid ? AppColors.meterGreen : AppColors.meterAmber,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showTripDetailsModal(BuildContext context, TripModel trip, TripManager manager) {
    final breakdown = FareBreakdown(
      baseFare: trip.baseFare,
      distanceKm: trip.distanceKm,
      perKmRate: manager.fareConfig.perKmRate,
      distanceFare: trip.distanceFare,
      waitingDurationSeconds: trip.waitingDurationSeconds,
      waitingMinutes: (trip.waitingDurationSeconds / 60.0).ceil(),
      waitingRatePerMin: manager.fareConfig.waitingRatePerMin,
      waitingFare: trip.waitingFare,
      totalFare: trip.totalFare,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.meterBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.meterCardBorder, width: 1.5)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRIP DETAILS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        Formatters.formatFullDateTime(trip.startTime),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FareBreakdownCard(
                breakdown: breakdown,
                currency: manager.fareConfig.currency,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.meterSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.meterCardBorder),
                ),
                child: Column(
                  children: [
                    _buildRow('Ref ID', trip.paymentReference ?? trip.id.substring(0, 8).toUpperCase()),
                    const Divider(color: AppColors.meterDivider),
                    _buildRow('Payment Method', trip.paymentMethod.toUpperCase()),
                    const Divider(color: AppColors.meterDivider),
                    _buildRow('Payment Status', trip.paymentStatus.toUpperCase()),
                    const Divider(color: AppColors.meterDivider),
                    _buildRow('Cloud Sync', trip.isSynced ? 'Synced to Supabase' : 'Stored Locally'),
                  ],
                ),
              ),
              if (trip.paymentStatus == 'pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.meterAmber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentQrScreen(trip: trip),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_rounded, size: 20),
                    label: const Text(
                      'COLLECT PAYMENT / VIEW QR',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
