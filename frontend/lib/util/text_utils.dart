import 'package:restrr/restrr.dart';

class TextUtils {
  const TextUtils._();

  static String formatCurrency(int amount, Currency currency, {String decimalSeparator = '.'}) {
    if (currency.decimalPlaces == 0) return '$amount${currency.symbol}';
    final String amountStr = amount.toString();
    if (amountStr.length <= currency.decimalPlaces) {
      return '0$decimalSeparator${amountStr.padLeft(currency.decimalPlaces, '0')}${currency.symbol}';
    }
    final String preDecimal = amountStr.substring(0, amountStr.length - currency.decimalPlaces);
    return '${preDecimal.isEmpty ? '0' : preDecimal}'
        '$decimalSeparator${amountStr.substring(amountStr.length - currency.decimalPlaces)}'
        '${currency.symbol}';
  }

  static String? formatIBAN(String? iban) {
    if (iban == null) return null;
    if (iban.length != 22) return iban;
    return '${iban.substring(0, 4)} ${iban.substring(4, 8)} ${iban.substring(8, 12)} ${iban.substring(12, 16)} ${iban.substring(16, 20)} ${iban.substring(20)}';
  }
}
