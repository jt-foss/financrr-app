import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/data/l10n_repository.dart';
import 'package:restrr/restrr.dart';

class TextUtils {
  const TextUtils._();

  static String formatBalanceWithCurrency(int amount, Currency currency) {
    return '${formatBalance(amount, currency.decimalPlaces, decimalSeparator, thousandsSeparator)}${currency.symbol}';
  }

  static String formatBalance(int amount, int decimalPlaces, String decimalSeparator, String thousandsSeparator) {
    if (decimalPlaces == 0) return amount.toString();
    final String amountStr = amount.toString();
    if (amountStr.length <= decimalPlaces) {
      return '0$decimalSeparator${amountStr.padLeft(decimalPlaces, '0')}';
    }
    final String preDecimal = amountStr.substring(0, amountStr.length - decimalPlaces);
    return '${preDecimal.isEmpty ? '0' : preDecimal}'
        '$decimalSeparator${amountStr.substring(amountStr.length - decimalPlaces)}';
  }

  static String? formatIBAN(String? iban) {
    if (iban == null || iban.length != 22) return null;
    return '${iban.substring(0, 4)} ${iban.substring(4, 8)} ${iban.substring(8, 12)} ${iban.substring(12, 16)} ${iban.substring(16, 20)} ${iban.substring(20)}';
  }
}
