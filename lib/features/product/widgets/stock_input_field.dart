import 'package:flutter/material.dart';

import '../../../../core/utils/unit_converter.dart';

class StockInputResult {
  final double baseStock;
  final String baseUnit;

  StockInputResult({
    required this.baseStock,
    required this.baseUnit,
  });
}

class StockInputField extends StatefulWidget {
  final Function(StockInputResult result) onChanged;

  const StockInputField({
    super.key,
    required this.onChanged,
  });

  @override
  State<StockInputField> createState() => _StockInputFieldState();
}

class _StockInputFieldState extends State<StockInputField> {
  final stockController = TextEditingController();

  String selectedUnit = 'pcs';

  final units = [
    'pcs',
    'lusin',
    'renceng',
    'gram',
    'kg',
    'ml',
    'liter',
  ];

  void updateStock() {
    final value = double.tryParse(stockController.text) ?? 0;

    final baseStock = UnitConverter.toBaseUnit(
      value: value,
      unit: selectedUnit,
    );

    final baseUnit = UnitConverter.baseUnitOf(selectedUnit);

    widget.onChanged(
      StockInputResult(
        baseStock: baseStock,
        baseUnit: baseUnit,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final inputValue = double.tryParse(stockController.text) ?? 0;

    final previewStock = UnitConverter.toBaseUnit(
      value: inputValue,
      unit: selectedUnit,
    );

    final previewUnit = UnitConverter.baseUnitOf(selectedUnit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Stok awal',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => updateStock(),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: selectedUnit,
          decoration: const InputDecoration(
            labelText: 'Satuan',
          ),
          items: units.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            selectedUnit = value;
            updateStock();
          },
        ),

        Text(
          'Disimpan sebagai: $previewStock $previewUnit',
            style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}