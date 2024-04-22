class JsonUtils {
  const JsonUtils._();

  static bool isInvalidType(Map<String, dynamic> json, String key, Type type, {bool nullable = false}) {
    return (json[key] == null && !nullable) && json[key].runtimeType != type;
  }

  static T? tryEnum<T extends Enum>(String? value, List<T> values) {
    if (value == null) {
      return null;
    }
    try {
      return values.firstWhere((e) => e.toString().split('.').last == value);
    } catch (e) {
      return null;
    }
  }
}
