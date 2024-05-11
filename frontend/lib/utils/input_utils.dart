import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:financrr_frontend/utils/text_utils.dart';

class InputValidators {
  const InputValidators._();

  static String? nonNull(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return L10nKey.commonRequiredObject.toString(namedArgs: {'object': fieldName});
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null) {
      return null;
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return L10nKey.commonUrlInvalid.toString();
    }
    return null;
  }

  static String? iban(String? value) {
    if (value == null || value.trim().isEmpty || TextUtils.formatIBAN(value) != null) {
      return null;
    }
    return L10nKey.commonIbanInvalid.toString();
  }
}
