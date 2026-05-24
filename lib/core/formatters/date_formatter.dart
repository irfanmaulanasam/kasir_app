import 'package:intl/intl.dart';

class DateFormatter {
  static String receiptDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMMM yyyy - HH:mm', 'id_ID').format(date);
  }
}