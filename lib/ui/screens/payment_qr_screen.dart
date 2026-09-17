import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
                    color: AppColors.meterSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.meterCardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('DISTANCE', '${widget.trip.distanceKm.toStringAsFixed(2)} km'),
                      _buildDivider(),
                      _buildMetricItem('WAITING', Formatters.formatDuration(widget.trip.waitingDurationSeconds)),
                      _buildDivider(),
                      _buildMetricItem('DURATION', Formatters.formatDuration(widget.trip.tripDurationSeconds)),
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
                    color: AppColors.meterCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.meterCardBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.meterAmber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prototype flow: QR generates exact amount intent. Driver verifies and confirms payment below before completing.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
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
                        backgroundColor: AppColors.meterGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onConfirmPayment(manager, 'upi', 'UPI Payment Confirmed'),
                      icon: const Icon(Icons.check_circle_rounded, size: 22),
                      label: const Text(
                        'MARK AS PAID (UPI)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Cash Payment Option
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.meterAmber, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _onConfirmPayment(manager, 'cash', 'Cash Payment Received'),
                      icon: const Icon(Icons.payments_rounded, color: AppColors.meterAmber, size: 20),
                      label: const Text(
                        'PAID VIA CASH',
                        style: TextStyle(
                          color: AppColors.meterAmber,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.meterGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.meterGreen),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.meterGreen, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'Payment Recorded (${_selectedMethod?.toUpperCase()})',
                          style: const TextStyle(
                            color: AppColors.meterGreen,
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

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 28,
      width: 1,
      color: AppColors.meterDivider,
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

    if (!mounted) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.black),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppColors.meterGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        manager.dismissSummaryAndReset();
        nav.popUntil((route) => route.isFirst);
      }
    });
  }

  void _confirmDiscardOrExit(BuildContext context, TripManager manager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.meterSurface,
        title: const Text('Exit Payment Screen?'),
        content: const Text('This trip will remain saved in Trip History as pending payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              manager.dismissSummaryAndReset();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('RETURN TO DASHBOARD'),
          ),
        ],
      ),
    );
  }
}
