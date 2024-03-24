import 'package:restrr/restrr.dart';

class TextUtils {
  const TextUtils._();

  static String formatCurrency(int amount, Currency currency, {String decimalSeparator = '.'}) {
    if (currency.decimalPlaces == 0) return '$amount${currency.symbol}';
    final String amountStr = amount.toString();
    final String preDecimal = amountStr.substring(0, amountStr.length - currency.decimalPlaces);
    return '${preDecimal.isEmpty ? '0' : preDecimal}'
        '$decimalSeparator${amountStr.substring(amountStr.length - currency.decimalPlaces)}'
        '${currency.symbol}';
  }
}
