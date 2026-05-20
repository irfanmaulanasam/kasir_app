import 'package:flutter/material.dart';

import '../../../core/utils/unit_converter.dart';

class StockConverterField extends StatefulWidget {

  const StockConverterField({
    super.key,
  });

  @override
  State<StockConverterField> createState()
      => _StockConverterFieldState();
}

class _StockConverterFieldState
    extends State<StockConverterField> {

  final controller =
      TextEditingController();

  String result = '';

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        TextField(

          controller: controller,

          keyboardType:
              TextInputType.number,

          decoration: const InputDecoration(
            labelText: 'Input stok',
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton(

          onPressed: () {

            final value =
                double.tryParse(
                  controller.text,
                ) ?? 0;

            final converted =
                UnitConverter.convert(

              value: value,

              from: 'kg',

              to: 'gram',
            );

            setState(() {

              result =
                  '$value kg = '
                  '$converted gram';
            });
          },

          child: const Text('Convert'),
        ),

        const SizedBox(height: 16),

        Text(result),
      ],
    );
  }
}