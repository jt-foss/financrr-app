class InputValidators {
  const InputValidators._();

  static String? nonNull(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName may not be null!';
    }
    return null;
  }

  static String? url(String? value) {
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
