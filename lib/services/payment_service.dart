import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  /// Builds standard NPCI UPI Intent URI for QR code generation & deep linking
  /// Format: upi://pay?pa=<vpa>&pn=<name>&am=<amount>&cu=INR&tn=<note>&tr=<ref>
  static String generateUpiUri({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionNote,
    required String transactionRef,
    String currency = 'INR',
  }) {
    final sanitizedUpi = upiId.trim();
    final sanitizedName = Uri.encodeComponent(payeeName.trim());
    final formattedAmount = amount.toStringAsFixed(2);
    final sanitizedNote = Uri.encodeComponent(transactionNote.trim());
    final sanitizedRef = Uri.encodeComponent(transactionRef.trim());

    return 'upi://pay?pa=$sanitizedUpi&pn=$sanitizedName&am=$formattedAmount&cu=$currency&tn=$sanitizedNote&tr=$sanitizedRef';
  }

  /// Validates standard Indian UPI ID / VPA format: e.g. handle@bank or phone@bank
  static bool isValidUpiId(String upiId) {
    final trimmed = upiId.trim();
    final regex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return regex.hasMatch(trimmed);
  }

  /// Generates a readable unique transaction reference code
  static String generateTransactionRef(String tripId) {
    final cleanId = tripId.replaceAll('-', '').toUpperCase();
    final prefix = cleanId.length > 6 ? cleanId.substring(0, 6) : cleanId;
    return 'MTR-$prefix';
  }

  /// Attempts to launch UPI payment app via deep-link (if supported on device)
  static Future<bool> launchUpiApp(String upiUri) async {
    try {
      final uri = Uri.parse(upiUri);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
