import '../../features/inventory/models/unit_model.dart';

class UnitConstants {

  static const List<UnitModel> units = [

    UnitModel(
      name: 'pcs',
      multiplier: 1,
    ),

    UnitModel(
      name: 'lusin',
      multiplier: 12,
    ),

    UnitModel(
      name: 'renceng',
      multiplier: 10,
    ),

    UnitModel(
      name: 'gram',
      multiplier: 1,
    ),

    UnitModel(
      name: 'kg',
      multiplier: 1000,
    ),

    UnitModel(
      name: 'ml',
      multiplier: 1,
    ),

    UnitModel(
      name: 'liter',
      multiplier: 1000,
    ),
  ];
}