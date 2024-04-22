import 'package:financrr_frontend/routing/page_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtension on BuildContext {
  void goPath(PagePath path, {Object? extra}) {
    go(path.fullPath, extra: extra);
  }

  Future<T?> pushPath<T extends Object?>(PagePath path, {Object? extra}) {
    return push(path.fullPath, extra: extra);
  }

  void replacePath(PagePath path, {Object? extra}) {
    replace(path.fullPath, extra: extra);
  }
}
