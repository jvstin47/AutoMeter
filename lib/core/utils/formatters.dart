import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
      customPattern: '$symbol#,##0.00',
    );
    return formatter.format(amount);
  }

  static String formatDistance(double km) {
    return '${km.toStringAsFixed(2)} km';
  }

  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDurationHuman(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    if (minutes < 1) {
      return '$totalSeconds sec';
    }
    final remainingSec = totalSeconds % 60;
    if (remainingSec == 0) {
      return '$minutes min';
    }
    return '$minutes min $remainingSec s';
  }

  static String formatWaitingMinutes(int seconds) {
    final minutes = (seconds / 60).ceil();
    return '${minutes.toString().padLeft(2, '0')} min';
  }

  static String formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);

    if (target == today) {
      return 'Today';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('dd MMM yyyy').format(dt);
    }
  }

  static String formatFullDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }
}
