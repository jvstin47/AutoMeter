import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/errors/app_exception.dart';

/// Domain service handling NPCI UPI payment URI generation and application launching.
class PaymentService {
  /// Builds standard NPCI UPI Intent URI for QR code generation and deep linking.
  /// Format: `upi://pay?pa=<vpa>&pn=<name>&am=<amount>&cu=INR&tn=<note>&tr=<ref>`
  static String generateUpiUri({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionNote,
    required String transactionRef,
    String currency = 'INR',
  }) {
    if (!isValidUpiId(upiId)) {
      debugPrint('[PaymentService] Warning: UPI ID "$upiId" does not conform to strict format.');
    }

    final sanitizedUpi = upiId.trim();
    final sanitizedName = Uri.encodeComponent(payeeName.trim());
    final formattedAmount = amount.toStringAsFixed(2);
    final sanitizedNote = Uri.encodeComponent(transactionNote.trim());
    final sanitizedRef = Uri.encodeComponent(transactionRef.trim());

    return 'upi://pay?pa=$sanitizedUpi&pn=$sanitizedName&am=$formattedAmount&cu=$currency&tn=$sanitizedNote&tr=$sanitizedRef';
  }

  /// Validates standard Indian UPI ID / Virtual Payment Address (VPA) format.
  /// Example valid formats: `name@okaxis`, `9876543210@paytm`.
  static bool isValidUpiId(String upiId) {
    final trimmed = upiId.trim();
    final regex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return regex.hasMatch(trimmed);
  }

  /// Generates a readable unique transaction reference code from trip UUID.
  static String generateTransactionRef(String tripId) {
    final cleanId = tripId.replaceAll('-', '').toUpperCase();
    final prefix = cleanId.length > 6 ? cleanId.substring(0, 6) : cleanId;
    return 'MTR-$prefix';
  }

  /// Attempts to launch UPI payment app via deep-link (if installed on device).
  static Future<bool> launchUpiApp(String upiUri) async {
    try {
      final uri = Uri.parse(upiUri);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } on FormatException catch (e) {
      debugPrint('[PaymentService] Malformed URI: $e');
      throw PaymentException('Malformed UPI payment URI: $upiUri', details: e);
    } catch (e) {
      debugPrint('[PaymentService] Error launching UPI app: $e');
      return false;
    }
  }
}
