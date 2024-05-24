import 'package:financrr_frontend/modules/settings/models/l10n.state.dart';
import 'package:financrr_frontend/utils/text_utils.dart';
import 'package:flutter/services.dart';
import 'package:restrr/restrr.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final L10nState l10n;
  final Currency currency;

  CurrencyInputFormatter({required this.l10n, required this.currency});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String unmaskedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final String oldCleaned = oldValue.text.replaceAll(l10n.decimalSeparator, '').replaceAll(l10n.thousandSeparator, '');
    // check whether we're deleting a character
    if (oldCleaned.length > newValue.text.length) {
      unmaskedText = unmaskedText.substring(0, unmaskedText.length - 1);
    }
    final String formatted = TextUtils.formatBalanceWithCurrency(l10n, int.tryParse(unmaskedText) ?? 0, currency);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
