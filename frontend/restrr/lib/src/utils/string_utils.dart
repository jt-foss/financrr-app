class StringUtils {
  const StringUtils._();

  /// Returns the number of occurrences of [search] in [str].
  static int count(String str, String search) {
    return search.allMatches(str).length;
  }
}
