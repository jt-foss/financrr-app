import 'package:logging/logging.dart';
import 'package:restrr/src/cache/batch_cache_view.dart';
import 'package:restrr/src/requests/route.dart';
import 'package:restrr/src/service/api_service.dart';
import 'package:restrr/src/service/currency_service.dart';
import 'package:restrr/src/service/user_service.dart';

import '../restrr.dart';
import 'cache/cache_view.dart';

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
    final RestResponse<HealthResponse> statusResponse = await Restrr.checkUri(uri, isWeb: options.isWeb);
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
    final RestResponse<User> response = await apiImpl._userService.login(username, password);
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
        await apiImpl._userService.register(username, password, email: email, displayName: displayName);
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
    final RestResponse<User> response = await apiImpl._userService.getSelf();
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

  /// Checks whether the given [uri] is valid and the API is healthy.
  static Future<RestResponse<HealthResponse>> checkUri(Uri uri, {bool isWeb = false}) async {
    return RequestHandler.request(
        route: StatusRoutes.health.compile(),
        mapper: (json) => EntityBuilder.buildHealthResponse(json),
        isWeb: isWeb,
        routeOptions: RouteOptions(hostUri: uri));
  }

  /// Retrieves the currently authenticated user.
  Future<User?> retrieveSelf({bool forceRetrieve = false});

  /// Logs out the current user.
  Future<bool> logout();

  Future<List<Currency>?> retrieveAllCurrencies({bool forceRetrieve = false});

  Future<Currency?> createCurrency(
      {required String name, required String symbol, required String isoCode, required int decimalPlaces});

  Future<Currency?> retrieveCurrencyById(ID id, {bool forceRetrieve = false});

  Future<bool> deleteCurrencyById(ID id);

  Future<Currency?> updateCurrencyById(ID id, {String? name, String? symbol, String? isoCode, int? decimalPlaces});
}

class RestrrImpl implements Restrr {
  @override
  final RestrrOptions options;
  @override
  final RouteOptions routeOptions;

  /* Services */

  late final UserService _userService = UserService(api: this);
  late final CurrencyService _currencyService = CurrencyService(api: this);

  /* Caches */

  late final RestrrEntityCacheView<User> userCache = RestrrEntityCacheView();
  late final RestrrEntityCacheView<Currency> currencyCache = RestrrEntityCacheView();

  late final RestrrEntityBatchCacheView<Currency> _currencyBatchCache = RestrrEntityBatchCacheView();

  RestrrImpl._({required this.options, required this.routeOptions});

  @override
  late final EntityBuilder entityBuilder = EntityBuilder(api: this);

  @override
  late final User selfUser;

  @override
  Future<User?> retrieveSelf({bool forceRetrieve = false}) async {
    return _getOrRetrieveSingle(
        key: selfUser.id,
        cacheView: userCache,
        retrieveFunction: (api) => api._userService.getSelf(),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<bool> logout() async {
    final RestResponse<bool> response = await _userService.logout();
    if (response.hasData && response.data! && !options.isWeb) {
      await CompiledRoute.cookieJar.deleteAll();
      return true;
    }
    return false;
  }

  @override
  Future<List<Currency>?> retrieveAllCurrencies({bool forceRetrieve = false}) async {
    return _getOrRetrieveMulti(
        batchCache: _currencyBatchCache,
        retrieveFunction: (api) => api._currencyService.retrieveAllCurrencies(),
    );
  }

  @override
  Future<Currency?> createCurrency(
      {required String name, required String symbol, required String isoCode, required int decimalPlaces}) async {
    final RestResponse<Currency> response = await _currencyService.createCurrency(
        name: name, symbol: symbol, isoCode: isoCode, decimalPlaces: decimalPlaces);
    return response.data;
  }

  @override
  Future<Currency?> retrieveCurrencyById(ID id, {bool forceRetrieve = false}) async {
    return _getOrRetrieveSingle(
        key: id,
        cacheView: currencyCache,
        retrieveFunction: (api) => api._currencyService.retrieveCurrencyById(id),
        forceRetrieve: forceRetrieve);
  }

  @override
  Future<bool> deleteCurrencyById(ID id) async {
    final RestResponse<bool> response = await _currencyService.deleteCurrencyById(id);
    return response.hasData && response.data!;
  }

  @override
  Future<Currency?> updateCurrencyById(ID id,
      {String? name, String? symbol, String? isoCode, int? decimalPlaces}) async {
    final RestResponse<Currency> response = await _currencyService.updateCurrencyById(id,
        name: name, symbol: symbol, isoCode: isoCode, decimalPlaces: decimalPlaces);
    return response.data;
  }

  Future<T?> _getOrRetrieveSingle<T extends RestrrEntity>(
      {required ID key,
      required RestrrEntityCacheView<T> cacheView,
      required Future<RestResponse<T>> Function(RestrrImpl) retrieveFunction,
      bool forceRetrieve = false}) async {
    if (!forceRetrieve && cacheView.contains(key)) {
      return cacheView.get(key)!;
    }
    final RestResponse<T> response = await retrieveFunction.call(this);
    return response.hasData ? response.data : null;
  }

  Future<List<T>?> _getOrRetrieveMulti<T extends RestrrEntity>(
      {required RestrrEntityBatchCacheView<T> batchCache,
      required Future<RestResponse<List<T>>> Function(RestrrImpl) retrieveFunction,
      bool forceRetrieve = false}) async {
    if (!forceRetrieve && batchCache.hasSnapshot) {
      return batchCache.get()!;
    }
    final RestResponse<List<T>> response = await retrieveFunction.call(this);
    if (response.hasData) {
      final List<T> remote = response.data!;
      batchCache.update(remote);
      return remote;
    }
    return null;
  }
}
