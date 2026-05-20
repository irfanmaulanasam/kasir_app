import '../constants/unit_constants.dart';

class UnitConverter {

  static double convert({

    required double value,
    required String from,
    required String to,
  }) {

    final fromUnit = UnitConstants.units.firstWhere(
      (e) => e.name == from,
    );

    final toUnit = UnitConstants.units.firstWhere(
      (e) => e.name == to,
    );

    return (value * fromUnit.multiplier)
        / toUnit.multiplier;
  }
}