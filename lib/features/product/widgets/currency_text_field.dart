import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/formatters/currency_formatter.dart';

class CurrencyTextField extends StatelessWidget {

  final TextEditingController controller;
  final String label;

  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return TextField(

      controller: controller,

      keyboardType: TextInputType.number,

      inputFormatters: [

        FilteringTextInputFormatter.digitsOnly,

        TextInputFormatter.withFunction(
          (oldValue, newValue) {

            final text =
                CurrencyFormatter.format(
                  newValue.text,
                );

            return TextEditingValue(

              text: text,

              selection: TextSelection.collapsed(
                offset: text.length,
              ),
            );
          },
        ),
      ],

      decoration: InputDecoration(
        labelText: label,
        prefixText: 'Rp ',
      ),
    );
  }
}