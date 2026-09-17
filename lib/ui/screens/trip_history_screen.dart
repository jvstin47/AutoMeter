import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
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
    final colors = context.meterColors;
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
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Icon(Icons.history_rounded, size: 48, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              Text(
                'No Completed Trips Yet',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a trip on the dashboard to calculate fares and record history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
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
                            color: isToday ? colors.meterAmber : colors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${Formatters.formatDate(trip.startTime)} • ${Formatters.formatTime(trip.startTime)}',
                            style: TextStyle(
                              color: isToday ? colors.meterAmber : colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        Formatters.formatCurrency(trip.totalFare, symbol: manager.fareConfig.currency),
                        style: TextStyle(
                          color: colors.meterAmber,
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
                    style: TextStyle(
                      color: colors.textPrimary,
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
                          _buildPaymentBadge(trip.paymentMethod, trip.paymentStatus, colors),
                          if (trip.isDemo) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Text(
                                'DEMO',
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 20),
                    ],
                  ),

                  // Show Pay Now Action if Pending
                  if (trip.paymentStatus != 'confirmed') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.meterAmber, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PaymentQrScreen(trip: trip)),
                          );
                        },
                        icon: Icon(Icons.qr_code_rounded, size: 16, color: colors.meterAmber),
                        label: Text(
                          'COLLECT PAYMENT / VIEW QR',
                          style: TextStyle(color: colors.meterAmber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentBadge(String? method, String status, MeterThemeColors colors) {
    final isPaid = status == 'confirmed';
    final isUpi = method == 'upi';

    Color bg;
    Color fg;
    String text;

    if (isPaid) {
      bg = isUpi ? colors.meterGreen.withOpacity(0.15) : colors.meterAmber.withOpacity(0.15);
      fg = isUpi ? colors.meterGreen : colors.meterAmber;
      text = isUpi ? 'PAID VIA UPI' : 'PAID CASH';
    } else {
      bg = colors.meterRed.withOpacity(0.15);
      fg = colors.meterRed;
      text = 'PAYMENT PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showTripDetailsModal(BuildContext context, TripModel trip, TripManager manager) {
    final colors = context.meterColors;
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
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: colors.cardBorder, width: 1.5)),
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
                      Text(
                        'TRIP DETAILS',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        Formatters.formatFullDateTime(trip.startTime),
                        style: TextStyle(
                          color: colors.textPrimary,
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
              // Meta details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.divider),
                ),
                child: Column(
                  children: [
                    _buildMetaRow('Trip ID', trip.id.substring(0, 8), colors),
                    Divider(color: colors.divider),
                    _buildMetaRow('Vehicle Number', manager.driverProfile.vehicleNumber, colors),
                    Divider(color: colors.divider),
                    _buildMetaRow('Driver', manager.driverProfile.name, colors),
                    Divider(color: colors.divider),
                    _buildMetaRow('Status', trip.paymentStatus.toUpperCase(), colors),
                    Divider(color: colors.divider),
                    _buildMetaRow('Cloud Synced', trip.isSynced ? 'Yes' : 'Pending', colors),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, MeterThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textMuted, fontSize: 12)),
          Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
