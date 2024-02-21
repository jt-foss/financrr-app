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

///
enum RestrrInitType { login, register }

/// A builder for creating a new [Restrr] instance.
/// The [Restrr] instance is created by calling [create].
class RestrrBuilder {
  final RestrrInitType initType;
  final Uri uri;
  String? sessionId;
  String? username;
  String? password;

  RestrrBuilder.login({required this.uri, required this.username, required this.password})
      : initType = RestrrInitType.login;

  /// Creates a new session with the given [uri].
  Future<RestResponse<Restrr>> create() async {
    Restrr.log.info('Attempting to initialize a session (${initType.name}) with $uri');
    // check if the URI is valid
    final RestResponse<HealthResponse> statusResponse = await Restrr.checkUri(uri);
    if (!statusResponse.hasData) {
      Restrr.log.warning('Invalid financrr URI: $uri');
      return RestrrError.invalidUri.toRestResponse();
    }
    Restrr.log.info('Host: $uri, API v${statusResponse.data!.apiVersion}');
    // create the API instance
    final RestrrImpl? api = await switch (initType) {
      RestrrInitType.register => throw UnimplementedError(),
      RestrrInitType.login => _handleLogin(username!, password!),
    };
    if (api == null) {
      Restrr.log.warning('Invalid credentials for user $username');
      return RestrrError.invalidCredentials.toRestResponse();
    }
    Restrr.log.info('Successfully logged in as ${api.selfUser.username}');
    return RestResponse(data: api);
  }

  /// Handles the login process.
  /// Returns a [RestrrImpl] instance if the login was successful, otherwise null.
  Future<RestrrImpl?> _handleLogin(String username, String password) async {
    final RestrrImpl api = RestrrImpl._();
    final RestResponse<User> userResponse = await UserService(api: api).login(username, password);
    if (!userResponse.hasData) {
      return null;
    }
    return api..selfUser = userResponse.data!;
  }
}

abstract class Restrr {
  static final Logger log = Logger('Restrr');
  static HostInformation hostInformation = HostInformation.empty();

  /// Getter for the [EntityBuilder] of this [Restrr] instance.
  EntityBuilder get entityBuilder;

  /// The currently authenticated user.
  User get selfUser;

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
}
