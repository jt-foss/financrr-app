class PagePathBuilder {
  final String path;
  final PagePathBuilder? parent;

  const PagePathBuilder(this.path) : parent = null;

  const PagePathBuilder.child({required this.parent, required this.path});

  PagePath build({Map<String, String>? params, Map<String, dynamic>? queryParams}) {
    String compiled = parent == null ? path : '${parent!.build().fullPath}/$path';
    if (params == null && queryParams == null) {
      return PagePath._(compiled);
    }
    final String initialPath = compiled;
    if (params != null && params.isNotEmpty) {
      for (MapEntry<String, String> entry in params.entries) {
        if (!initialPath.contains(':${entry.key}')) {
          throw StateError('Path does not contain pathParam :${entry.key}!');
        }
        compiled = compiled.replaceAll(':${entry.key}', entry.value.toString());
      }
    }
    if (queryParams != null && queryParams.isNotEmpty) {
      bool first = true;
      for (MapEntry<String, dynamic> entry in queryParams.entries) {
        compiled += '${first ? '?' : '&'}${entry.key}=${entry.value}';
        first = false;
      }
    }
    return PagePath._(compiled);
  }
}

class PagePath {
  final String fullPath;

  const PagePath._(this.fullPath);
}
