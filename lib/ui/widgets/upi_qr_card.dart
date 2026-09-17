import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../services/payment_service.dart';

class UpiQrCard extends StatelessWidget {
  final String upiId;
  final String payeeName;
  final double amount;
  final String transactionRef;
  final String currency;

  const UpiQrCard({
    super.key,
    required this.upiId,
    required this.payeeName,
    required this.amount,
    required this.transactionRef,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final upiUri = PaymentService.generateUpiUri(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: 'Auto Rickshaw Fare $transactionRef',
      transactionRef: transactionRef,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.meterSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.meterCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.meterGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.meterGreen.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_2_rounded, size: 14, color: AppColors.meterGreen),
                    SizedBox(width: 6),
                    Text(
                      'DYNAMIC UPI QR',
                      style: TextStyle(
                        color: AppColors.meterGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Code in White Container for Maximum Scanner Contrast
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: QrImageView(
              data: upiUri,
              version: QrVersions.auto,
              size: 220.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount to Pay
          Text(
            Formatters.formatCurrency(amount, symbol: currency),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'SCAN WITH ANY UPI APP',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Supported App Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppTag('GPay'),
              const SizedBox(width: 8),
              _buildAppTag('PhonePe'),
              const SizedBox(width: 8),
              _buildAppTag('Paytm'),
              const SizedBox(width: 8),
              _buildAppTag('BHIM'),
            ],
          ),
          const SizedBox(height: 16),

          // Driver & UPI Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.meterCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.meterDivider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payee: $payeeName',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'UPI ID: $upiId',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy UPI String',
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.meterAmber),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: upiUri));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UPI Intent URI copied to clipboard'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.meterSurface,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Try Launching directly
          OutlinedButton.icon(
            onPressed: () async {
              final launched = await PaymentService.launchUpiApp(upiUri);
              if (!launched && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No external UPI app found on this test device. Scan QR with second phone!'),
                    backgroundColor: AppColors.meterSurface,
                  ),
                );
              }
            },
            icon: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.meterAmber),
            label: const Text(
              'Open UPI App on Device',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.meterCardBorder.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
