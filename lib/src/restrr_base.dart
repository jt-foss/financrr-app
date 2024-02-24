import 'package:cookie_jar/cookie_jar.dart';
import 'package:logging/logging.dart';

import '../restrr.dart';

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
  final CookieJar? cookieJar;

  const RestrrOptions({this.cookieJar});
}

enum RestrrInitType { login, register }

/// A builder for creating a new [Restrr] instance.
/// The [Restrr] instance is created by calling [create].
class RestrrBuilder {
  final RestrrInitType initType;
  final Uri uri;
  String? sessionId;
  String? username;
  String? password;
  String? email;
  String? displayName;

  final RestrrOptions options = RestrrOptions();

  RestrrBuilder.login({required this.uri, required this.username, required this.password})
      : initType = RestrrInitType.login;

  RestrrBuilder.register(
      {required this.uri, required this.username, required this.password, this.email, this.displayName})
      : initType = RestrrInitType.register;

  /// Creates a new session with the given [uri].
  Future<RestResponse<Restrr>> create() async {
    if (options.cookieJar != null) {
      CompiledRoute.cookieJar = options.cookieJar;
    }
    Restrr.log.info('Attempting to initialize a session (${initType.name}) with $uri');
    // check if the URI is valid
    final RestResponse<HealthResponse> statusResponse = await Restrr.checkUri(uri);
    if (statusResponse.hasError) {
      Restrr.log.warning('Invalid financrr URI: $uri');
      return statusResponse.error == RestrrError.unknown
          ? RestrrError.invalidUri.toRestResponse()
          : statusResponse.error?.toRestResponse() ?? RestrrError.invalidUri.toRestResponse();
    }
    Restrr.log.info('Host: $uri, API v${statusResponse.data!.apiVersion}');
    return switch (initType) {
      RestrrInitType.register => _handleRegistration(username!, password!, email: email, displayName: displayName),
      RestrrInitType.login => _handleLogin(username!, password!),
    };
  }

  Future<RestResponse<RestrrImpl>> _handleLogin(String username, String password) async {
    final RestrrImpl api = RestrrImpl._();
    final RestResponse<User> userResponse = await UserService(api: api).login(username, password);
    if (!userResponse.hasData) {
      Restrr.log.warning('Invalid credentials for user $username');
      return RestrrError.invalidCredentials.toRestResponse();
    }
    api.selfUser = userResponse.data!;
    Restrr.log.info('Successfully logged in as ${api.selfUser.username}');
    return RestResponse(data: api);
  }

  Future<RestResponse<RestrrImpl>> _handleRegistration(String username, String password,
      {String? email, String? displayName}) async {
    final RestrrImpl api = RestrrImpl._();
    final RestResponse<User> response =
        await UserService(api: api).register(username, password, email: email, displayName: displayName);
    if (response.hasError) {
      Restrr.log.warning('Failed to register user $username');
      return response.error?.toRestResponse() ?? RestrrError.unknown.toRestResponse();
    }
    api.selfUser = response.data!;
    Restrr.log.info('Successfully registered & logged in as ${api.selfUser.username}');
    return RestResponse(data: api);
  }
}

abstract class Restrr {
  static final Logger log = Logger('Restrr');
  static HostInformation hostInformation = HostInformation.empty();

  /// Getter for the [EntityBuilder] of this [Restrr] instance.
  EntityBuilder get entityBuilder;

  /// The currently authenticated user.
  User get selfUser;

  Future<bool> logout();

  /// Checks whether the given [uri] is valid and the API is healthy.
  static Future<RestResponse<HealthResponse>> checkUri(Uri uri) async {
    hostInformation = hostInformation.copyWith(hostUri: uri, apiVersion: -1);
    return ApiService.request(
        route: StatusRoutes.health.compile(),
        mapper: (json) => EntityBuilder.buildHealthResponse(json)).then((response) {
      if (response.hasData && response.data!.healthy) {
        // if successful, update the API version
        hostInformation = hostInformation.copyWith(apiVersion: response.data!.apiVersion);
      }
      return response;
    });
  }
}

class RestrrImpl implements Restrr {
  RestrrImpl._();

  @override
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  @override
  late final User selfUser;

  @override
  Future<bool> logout() async {
    final RestResponse<bool> response = await UserService(api: this).logout();
    if (response.hasData && response.data! && CompiledRoute.cookieJar != null) {
      await CompiledRoute.cookieJar?.deleteAll();
      return true;
    }
    return false;
  }
}
