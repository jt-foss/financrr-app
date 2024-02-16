import '../restrr.dart';

enum SessionInitType { refresh, login, register }

class HostInformation {
  final String? hostUrl;
  final int apiVersion;

  bool get hasHostUrl => hostUrl != null;

  const HostInformation({required this.hostUrl, this.apiVersion = 1});

  const HostInformation.empty()
      : hostUrl = null,
        apiVersion = 1;

  HostInformation copyWith({String? hostUrl, int? apiVersion}) {
    return HostInformation(
      hostUrl: hostUrl ?? this.hostUrl,
      apiVersion: apiVersion ?? this.apiVersion,
    );
  }
}

class RestrrOptions {
  const RestrrOptions();
}

class RestrrBuilder {
  final SessionInitType sessionInitType;
  final String hostUrl;
  String? sessionId;
  String? email;
  String? password;
  String? mfaCode;

  RestrrOptions options = RestrrOptions();

  RestrrBuilder.refresh({required this.hostUrl, required this.sessionId}) : sessionInitType = SessionInitType.refresh;

  RestrrBuilder.login({required this.hostUrl, required this.email, required this.password, this.mfaCode})
      : sessionInitType = SessionInitType.login;

  RestrrBuilder.register({required this.hostUrl, required this.email, required this.password, this.mfaCode})
      : sessionInitType = SessionInitType.register;

  Future<RestResponse<RestrrImpl>> create() async {
    // TODO: implement
    return RestResponse(data: null);
  }
}

abstract class Restrr {
  static HostInformation hostInformation = HostInformation.empty();

  /// Getter for the [EntityBuilder] of this [Restrr] instance.
  EntityBuilder get entityBuilder;

  static Future<HostUrlCheckResult> checkHostUri(Uri hostUri) async {
    return HostUrlCheckResult.healthy;
  }

  static Future<HostUrlCheckResult> checkHostUrl(String hostUrl) async {
    final Uri? uri = Uri.tryParse(hostUrl);
    if (uri == null) {
      return HostUrlCheckResult.invalidUri;
    }
    hostInformation = hostInformation.copyWith(hostUrl: hostUrl);
    return checkHostUri(uri);
  }
}

class RestrrImpl implements Restrr {
  @override
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);
}

enum HostUrlCheckResult { healthy, unhealthy, invalidUri, unknown }
