import 'package:flutter/cupertino.dart';

class InputValidators {
  const InputValidators._();

  static String? url(BuildContext context, String? value) {
    if (value == null) {
      return null;
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return 'Please provide a valid URL';
    }
    return null;
  }
}
