import 'package:financrr_frontend/utils/text_utils.dart';
import 'package:flutter/services.dart';
import 'package:restrr/restrr.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final String symbol;
  final int decimalPlaces;
  final String decimalSeparator;
  final String thousandSeparator;

  const MoneyInputFormatter({required this.symbol, required this.decimalPlaces, required this.decimalSeparator, required this.thousandSeparator});

  MoneyInputFormatter.fromCurrency(
      {required Currency currency, required this.decimalSeparator, required this.thousandSeparator})
      : symbol = currency.symbol,
        decimalPlaces = currency.decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String formatted =
        TextUtils.formatBalance(int.tryParse(numbers) ?? 0, decimalPlaces, decimalSeparator, thousandSeparator);
    return newValue.copyWith(
      text: '$formatted$symbol',
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
