class CurrencyFormatter {
  static int parse(dynamic value) {
    if (value is int) return value;

    return int.tryParse(
          value
              .toString()
              .replaceAll('.', '')
              .replaceAll('Rp', '')
              .trim(),
        ) ??
        0;
  }

  static String format(dynamic value) {
    final number = parse(value);

    return 'Rp ${number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  static String formatInput(String value) {
    final number = value.replaceAll('.', '').replaceAll('Rp', '').trim();

    if (number.isEmpty) return '';

    return number.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}