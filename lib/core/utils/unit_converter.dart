class UnitConverter {
  static double toBaseUnit({
    required double value,
    required String unit,
  }) {
    switch (unit) {
      case 'kg':
        return value * 1000; // simpan gram

      case 'gram':
        return value;

      case 'liter':
        return value * 1000; // simpan ml

      case 'ml':
        return value;

      case 'lusin':
        return value * 12; // simpan pcs

      case 'renceng':
        return value * 10; // simpan pcs / sachet

      case 'pcs':
        return value;

      default:
        return value;
    }
  }

  static String baseUnitOf(String unit) {
    switch (unit) {
      case 'kg':
      case 'gram':
        return 'gram';

      case 'liter':
      case 'ml':
        return 'ml';

      case 'lusin':
      case 'renceng':
      case 'pcs':
        return 'pcs';

      default:
        return unit;
    }
  }
}