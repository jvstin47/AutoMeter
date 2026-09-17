import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/meter_theme_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/trip_model.dart';
import '../../services/fare_engine.dart';
import '../../services/trip_manager.dart';
import '../widgets/fare_breakdown_card.dart';
import '../widgets/upi_qr_card.dart';

class PaymentQrScreen extends StatefulWidget {
  final TripModel trip;

  const PaymentQrScreen({super.key, required this.trip});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _isConfirmed = false;
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<TripManager>();
    final colors = context.meterColors;

    final breakdown = FareBreakdown(
      baseFare: widget.trip.baseFare,
      distanceKm: widget.trip.distanceKm,
      perKmRate: manager.fareConfig.perKmRate,
      distanceFare: widget.trip.distanceFare,
      waitingDurationSeconds: widget.trip.waitingDurationSeconds,
      waitingMinutes: (widget.trip.waitingDurationSeconds / 60.0).ceil(),
      waitingRatePerMin: manager.fareConfig.waitingRatePerMin,
      waitingFare: widget.trip.waitingFare,
      totalFare: widget.trip.totalFare,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmDiscardOrExit(context, manager);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'TRIP COMPLETED',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => _confirmDiscardOrExit(context, manager),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Trip Metrics Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('DISTANCE', '${widget.trip.distanceKm.toStringAsFixed(2)} km', colors),
                      _buildDivider(colors),
                      _buildMetricItem('WAITING', Formatters.formatDuration(widget.trip.waitingDurationSeconds), colors),
                      _buildDivider(colors),
                      _buildMetricItem('DURATION', Formatters.formatDuration(widget.trip.tripDurationSeconds), colors),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // DYNAMIC UPI QR CARD
                UpiQrCard(
                  upiId: manager.driverProfile.upiId,
                  payeeName: manager.driverProfile.name,
                  amount: widget.trip.totalFare,
                  transactionRef: widget.trip.paymentReference ?? 'MTR-${widget.trip.id.substring(0, 5)}',
                  currency: manager.fareConfig.currency,
                ),
                const SizedBox(height: 20),

                // DETAILED FARE BREAKDOWN
                FareBreakdownCard(
                  breakdown: breakdown,
                  currency: manager.fareConfig.currency,
                ),
                const SizedBox(height: 20),

                // PROTOTYPE VERIFICATION NOTICE (Section 16 requirement)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: colors.meterAmber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prototype flow: QR generates exact amount intent. Driver verifies and confirms payment below before completing.',
                          style: TextStyle(color: colors.textMuted, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // PAYMENT ACTION BUTTONS
                if (!_isConfirmed) ...[
                  // 1. Confirm UPI Payment
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.meterGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onConfirmPayment(manager, 'upi', 'UPI Payment Confirmed'),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                      label: const Text(
                        'MARK AS PAID (UPI)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Paid via Cash Alternative
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.cardBorder, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onConfirmPayment(manager, 'cash', 'Cash Payment Confirmed'),
                      icon: Icon(Icons.money_rounded, color: colors.meterAmber, size: 20),
                      label: Text(
                        'COLLECTED IN CASH',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Already Confirmed Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.meterGreen),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_rounded, color: colors.meterGreen, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Payment Recorded (${_selectedMethod?.toUpperCase()})',
                          style: TextStyle(
                            color: colors.meterGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () {
                            manager.dismissSummaryAndReset();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          child: const Text('BACK TO DASHBOARD'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, MeterThemeColors colors) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(MeterThemeColors colors) {
    return Container(
      height: 28,
      width: 1,
      color: colors.divider,
    );
  }

  void _onConfirmPayment(TripManager manager, String method, String message) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() {
      _isConfirmed = true;
      _selectedMethod = method;
    });

    await manager.confirmPayment(
      paymentMethod: method,
      paymentStatus: 'confirmed',
    );

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.meterGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        manager.dismissSummaryAndReset();
        nav.popUntil((route) => route.isFirst);
      }
    });
  }

  void _confirmDiscardOrExit(BuildContext context, TripManager manager) {
    final colors = context.meterColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: const Text('Close Trip Summary?'),
        content: const Text(
          'If you close now without confirming, this trip will remain saved in History as Unpaid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('STAY'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.meterRed),
            onPressed: () {
              Navigator.pop(ctx);
              manager.dismissSummaryAndReset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('CLOSE & RETURN HOME'),
          ),
        ],
      ),
    );
  }
}
