import 'package:intl/intl.dart';

class DateFormatter {
  static String transactionDate(dynamic timestamp) {
    final value = timestamp is int
        ? timestamp
        : int.tryParse(timestamp.toString()) ?? 0;

    final date = DateTime.fromMillisecondsSinceEpoch(value);

    return DateFormat(
      'dd MMM yyyy • HH:mm',
      'id_ID',
    ).format(date);
  }

  static String receiptDate(dynamic timestamp) {
    final value = timestamp is int
        ? timestamp
        : int.tryParse(timestamp.toString()) ?? 0;

    final date = DateTime.fromMillisecondsSinceEpoch(value);

    return DateFormat(
      'dd MMMM yyyy • HH:mm',
      'id_ID',
    ).format(date);
  }
}