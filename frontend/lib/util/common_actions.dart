import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../pages/authentication/state/authentication_provider.dart';
import '../pages/splash_page.dart';

class CommonActions {
  const CommonActions._();

  static Future<void> logOut(State state, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (state.mounted) state.context.pushPath(SplashPage.pagePath.build());
  }

  static Future<void> copyToClipboard(State state, String text, {bool showCopiedValue = false}) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (state.mounted) state.context.showSnackBar('Copied ${showCopiedValue ? '"$text" ' : ''}to clipboard!');
  }
}
