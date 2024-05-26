class TextUtils {
  const TextUtils._();

  static String? formatIBAN(String? iban) {
    if (iban == null || iban.length != 22) return null;
    return '${iban.substring(0, 4)} ${iban.substring(4, 8)} ${iban.substring(8, 12)} ${iban.substring(12, 16)} ${iban.substring(16, 20)} ${iban.substring(20)}';
  }
}
