class CurrencyFormatter {
  static String format(dynamic value) {
    final number = value is int
        ? value
        : int.tryParse(
              value.toString().replaceAll('.', '').replaceAll('Rp', '').trim(),
            ) ??
            0;

    return 'Rp ${number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  static String formatInput(String value) {
    final number = value.replaceAll('.', '').trim();

    if (number.isEmpty) return '';

    return number.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  static int parse(String value) {
    return int.tryParse(
          value.replaceAll('.', '').replaceAll('Rp', '').trim(),
        ) ??
        0;
  }
}