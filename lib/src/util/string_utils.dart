class StringUtils {
  const StringUtils._();

  static int count(String str, String search) {
    return search.allMatches(str).length;
  }
}
