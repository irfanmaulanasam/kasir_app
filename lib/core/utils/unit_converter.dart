class UnitConverter {
  static double toBaseUnit({
    required double value,
    required String unit,
  }) {
    switch (unit) {

      case 'kodi':
        return value *20;

      case 'lusin':
        return value * 12; 

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