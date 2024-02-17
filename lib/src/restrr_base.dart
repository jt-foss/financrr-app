import 'package:restrr/src/service/api_service.dart';

import '../restrr.dart';

enum SessionInitType { refresh, login, register }

class HostInformation {
  final Uri? hostUri;
  final int apiVersion;

  bool get hasHostUrl => hostUri != null;

  const HostInformation({required this.hostUri, this.apiVersion = 1});

  const HostInformation.empty()
      : hostUri = null,
        apiVersion = -1;

  HostInformation copyWith({Uri? hostUri, int? apiVersion}) {
    return HostInformation(
      hostUri: hostUri ?? this.hostUri,
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

  static Future<RestResponse<HealthResponse>> checkUri(Uri uri) async {
    hostInformation = hostInformation.copyWith(hostUri: uri, apiVersion: -1);
    return ApiService.request(route: StatusRoutes.health.compile(), mapper: (json) => EntityBuilder.buildHealthResponse(json))
        .then((response) {
      if (response.hasData && response.data!.healthy) {
        hostInformation = hostInformation.copyWith(apiVersion: response.data!.apiVersion);
      }
      return response;
    });
  }
}

class RestrrImpl implements Restrr {
  @override
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);
}

enum HostUrlCheckResult { healthy, unhealthy, invalidUri, unknown }
