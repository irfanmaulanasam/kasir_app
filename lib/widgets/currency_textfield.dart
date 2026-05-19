import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyTextField extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final Function (String)? onChanged;
  const CurrencyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.onChanged,
  });

  String formatRupiah(String value) {

    if (value.isEmpty) return '';

    final number =
        int.tryParse(
          value.replaceAll('.', ''),
        ) ?? 0;

    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(number);
  }

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

            final text =
                formatRupiah(newValue.text);

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
        border: const OutlineInputBorder(),
      ),
    );
  }
}