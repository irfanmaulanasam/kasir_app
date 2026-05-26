import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/currency_formatter.dart';

class CurrencyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(String)? onChanged;

  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        TextInputFormatter.withFunction(
          (oldValue, newValue) {
            final text = CurrencyFormatter.formatInput(newValue.text);

            return TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(
                offset: text.length,
              ),
            );
          },
        ),
      ],
      decoration: const InputDecoration(
        prefixText: 'Rp ',
        border: OutlineInputBorder(),
      ).copyWith(
        labelText: label,
      ),
    );
  }
}