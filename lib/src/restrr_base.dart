import 'package:logging/logging.dart';
import 'package:restrr/src/requests/route.dart';
import 'package:restrr/src/service/api_service.dart';
import 'package:restrr/src/service/user_service.dart';

import '../restrr.dart';

class RestrrOptions {
  final bool isWeb;
  const RestrrOptions({this.isWeb = false});
}

enum RestrrInitType { login, register, savedSession }

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

  RestrrOptions options = RestrrOptions();

  RestrrBuilder.login({required this.uri, required this.username, required this.password})
      : initType = RestrrInitType.login;

  RestrrBuilder.register(
      {required this.uri, required this.username, required this.password, this.email, this.displayName})
      : initType = RestrrInitType.register;

  RestrrBuilder.savedSession({required this.uri}) : initType = RestrrInitType.savedSession;

  /// Creates a new session with the given [uri].
  Future<RestResponse<Restrr>> create() async {
    Restrr.log.info('Attempting to initialize a session (${initType.name}) with $uri');
    // check if the URI is valid
    final RestResponse<HealthResponse> statusResponse = await Restrr.checkUri(uri);
    if (statusResponse.hasError) {
      Restrr.log.warning('Invalid financrr URI: $uri');
      return statusResponse.error == RestrrError.unknown
          ? RestrrError.invalidUri.toRestResponse()
          : statusResponse.error?.toRestResponse(statusCode: statusResponse.statusCode) ??
              RestrrError.invalidUri.toRestResponse();
    }
    Restrr.log.info('Host: $uri, API v${statusResponse.data!.apiVersion}');
    final RestrrImpl apiImpl = RestrrImpl._(
        options: options, routeOptions: RouteOptions(hostUri: uri, apiVersion: statusResponse.data!.apiVersion));
    return switch (initType) {
      RestrrInitType.register =>
        _handleRegistration(apiImpl, username!, password!, email: email, displayName: displayName),
      RestrrInitType.login => _handleLogin(apiImpl, username!, password!),
      RestrrInitType.savedSession => _handleSavedSession(apiImpl),
    };
  }

  /// Logs in with the given [username] and [password].
  Future<RestResponse<RestrrImpl>> _handleLogin(RestrrImpl apiImpl, String username, String password) async {
    final RestResponse<User> response = await apiImpl.userService.login(username, password);
    if (!response.hasData) {
      Restrr.log.warning('Invalid credentials for user $username');
      return RestrrError.invalidCredentials.toRestResponse(statusCode: response.statusCode);
    }
    apiImpl.selfUser = response.data!;
    Restrr.log.info('Successfully logged in as ${apiImpl.selfUser.username}');
    return RestResponse(data: apiImpl, statusCode: response.statusCode);
  }

  /// Registers a new user and logs in.
  Future<RestResponse<RestrrImpl>> _handleRegistration(RestrrImpl apiImpl, String username, String password,
      {String? email, String? displayName}) async {
    final RestResponse<User> response =
        await apiImpl.userService.register(username, password, email: email, displayName: displayName);
    if (response.hasError) {
      Restrr.log.warning('Failed to register user $username');
      return response.error?.toRestResponse(statusCode: response.statusCode) ?? RestrrError.unknown.toRestResponse();
    }
    apiImpl.selfUser = response.data!;
    Restrr.log.info('Successfully registered & logged in as ${apiImpl.selfUser.username}');
    return RestResponse(data: apiImpl, statusCode: response.statusCode);
  }

  /// Attempts to refresh the session with still saved credentials.
  Future<RestResponse<RestrrImpl>> _handleSavedSession(RestrrImpl apiImpl) async {
    final RestResponse<User> response = await apiImpl.userService.getSelf();
    if (response.hasError) {
      Restrr.log.warning('Failed to refresh session');
      return response.error?.toRestResponse(statusCode: response.statusCode) ?? RestrrError.unknown.toRestResponse();
    }
    apiImpl.selfUser = response.data!;
    Restrr.log.info('Successfully refreshed session for ${apiImpl.selfUser.username}');
    return RestResponse(data: apiImpl, statusCode: response.statusCode);
  }
}

abstract class Restrr {
  static final Logger log = Logger('Restrr');

  /// Getter for the [EntityBuilder] of this [Restrr] instance.
  EntityBuilder get entityBuilder;

  RestrrOptions get options;
  RouteOptions get routeOptions;

  /// The currently authenticated user.
  User get selfUser;

  Future<bool> logout();

  /// Checks whether the given [uri] is valid and the API is healthy.
  static Future<RestResponse<HealthResponse>> checkUri(Uri uri, {bool isWeb = false}) async {
    return RequestHandler.request(
        route: StatusRoutes.health.compile(),
        mapper: (json) => EntityBuilder.buildHealthResponse(json),
        isWeb: isWeb,
        routeOptions: RouteOptions(hostUri: uri));
  }
}

class RestrrImpl implements Restrr {
  @override
  final RestrrOptions options;
  @override
  final RouteOptions routeOptions;

  late final UserService userService = UserService(api: this);

  RestrrImpl._({required this.options, required this.routeOptions});

  @override
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  @override
  late final User selfUser;

  @override
  Future<bool> logout() async {
    final RestResponse<bool> response = await UserService(api: this).logout();
    if (response.hasData && response.data! && !options.isWeb) {
      await CompiledRoute.cookieJar.deleteAll();
      return true;
    }
    return false;
  }
}
