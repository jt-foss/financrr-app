import 'package:financrr_frontend/data/host_repository.dart';
import 'package:financrr_frontend/data/repositories.dart';
import 'package:financrr_frontend/pages/auth/server_info_page.dart';
import 'package:financrr_frontend/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:restrr/restrr.dart';

import '../pages/core/dashboard_page.dart';

class SessionRepository extends SecureStringRepository {
  const SessionRepository({required super.storage});

  @override
  String get key => 'sessionToken';
}

class SessionService {
  const SessionService._();

  static Future<bool> hasSession() => Repositories.sessionRepository.exists();

  static Future<bool> attemptRecovery(BuildContext context) async {
    final HostPreferences hostPrefs = HostService.get();
    if (!(await hasSession()) || hostPrefs.hostUrl.isEmpty) {
      return false;
    }
    final String token = (await Repositories.sessionRepository.read())!;
    try {
      final Restrr api =
          await RestrrBuilder(uri: Uri.parse(hostPrefs.hostUrl), options: const RestrrOptions(isWeb: kIsWeb))
              .refresh(sessionToken: token);
      login(context, api);
      return true;
    } on RestrrException catch (_) {}
    return false;
  }

  static Future<void> login(BuildContext context, Restrr api) async {
    context.authNotifier.setApi(api);
    context.pushPath(DashboardPage.pagePath.build());
    await Repositories.sessionRepository.write(api.session.token);
  }

  static Future<bool> logout(BuildContext context, Restrr api) async {
    final bool success = await api.deleteCurrentSession();
    if (success) {
      context.authNotifier.setApi(null);
      context.pushPath(ServerInfoPage.pagePath.build());
      await Repositories.sessionRepository.delete();
    }
    return success;
  }
}
