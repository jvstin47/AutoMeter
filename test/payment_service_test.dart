import 'package:flutter_test/flutter_test.dart';
import 'package:smart_fare_meter/services/payment_service.dart';

void main() {
  group('PaymentService Tests', () {
    test('Generates valid NPCI UPI uri', () {
      final uri = PaymentService.generateUpiUri(
        upiId: 'ramesh.auto@okhdfcbank',
        payeeName: 'Ramesh Kumar',
        amount: 82.0,
        transactionNote: 'Auto Rickshaw Fare',
        transactionRef: 'MTR-TRIP01',
      );

      expect(uri, contains('upi://pay?'));
      expect(uri, contains('pa=ramesh.auto@okhdfcbank'));
      expect(uri, contains('pn=Ramesh%20Kumar'));
      expect(uri, contains('am=82.00'));
      expect(uri, contains('cu=INR'));
      expect(uri, contains('tn=Auto%20Rickshaw%20Fare'));
      expect(uri, contains('tr=MTR-TRIP01'));
    });

    test('Validates UPI IDs correctly', () {
      expect(PaymentService.isValidUpiId('ramesh@okhdfcbank'), isTrue);
      expect(PaymentService.isValidUpiId('9876543210@paytm'), isTrue);
      expect(PaymentService.isValidUpiId('autorickshaw.blore@sbi'), isTrue);

      expect(PaymentService.isValidUpiId('invalid_no_at'), isFalse);
      expect(PaymentService.isValidUpiId('user@'), isFalse);
      expect(PaymentService.isValidUpiId(''), isFalse);
    });
  });
}
