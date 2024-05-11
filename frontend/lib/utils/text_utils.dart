import 'package:financrr_frontend/modules/settings/models/l10n.state.dart';
import 'package:restrr/restrr.dart';

class TextUtils {
  const TextUtils._();

  static String formatBalanceWithCurrency(L10nState l10n, int amount, Currency currency) {
    return '${formatBalance(amount, currency.decimalPlaces, l10n.decimalSeparator, l10n.thousandSeparator)}${currency.symbol}';
  }

  static String formatBalance(int amount, int decimalPlaces, String decimalSeparator, String thousandSeparator) {
    if (decimalPlaces == 0) return amount.toString();
    final String amountStr = amount.toString();
    if (amountStr.length <= decimalPlaces) {
      return '0$decimalSeparator${amountStr.padLeft(decimalPlaces, '0')}';
    }
    String preDecimal = amountStr.substring(0, amountStr.length - decimalPlaces);
    for (int i = preDecimal.length - 3; i > 0; i -= 3) {
      preDecimal = '${preDecimal.substring(0, i)}$thousandSeparator${preDecimal.substring(i)}';
    }
    return '${preDecimal.isEmpty ? '0' : preDecimal}'
        '$decimalSeparator${amountStr.substring(amountStr.length - decimalPlaces)}';
  }

  static String? formatIBAN(String? iban) {
    if (iban == null || iban.length != 22) return null;
    return '${iban.substring(0, 4)} ${iban.substring(4, 8)} ${iban.substring(8, 12)} ${iban.substring(12, 16)} ${iban.substring(16, 20)} ${iban.substring(20)}';
  }
}
