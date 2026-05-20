import 'package:intl/intl.dart';

class CurrencyFormatter {

  static String format(String value) {

    if (value.isEmpty) return '';

    final number =
        int.tryParse(
          value.replaceAll('.', ''),
        ) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(number);
  }
}