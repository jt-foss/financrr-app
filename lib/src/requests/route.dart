import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../../restrr.dart';

class Route {
  final String method;
  final String path;
  final int paramCount;
  final bool isVersioned;

  Route._(this.method, this.path, {this.isVersioned = true})
      : assert(StringUtils.count(path, '{') == StringUtils.count(path, '}')),
        paramCount = StringUtils.count(path, '{');

  Route.get(String path, {bool isVersioned = true}) : this._('GET', path, isVersioned: isVersioned);

  Route.post(String path, {bool isVersioned = true}) : this._('POST', path, isVersioned: isVersioned);

  Route.put(String path, {bool isVersioned = true}) : this._('PUT', path, isVersioned: isVersioned);

  Route.delete(String path, {bool isVersioned = true}) : this._('DELETE', path, isVersioned: isVersioned);

  Route.patch(String path, {bool isVersioned = true}) : this._('PATCH', path, isVersioned: isVersioned);

  static Future<ErrorResponse> asErrorResponse(DioException error) async {
    // TODO: implement
    return ErrorResponse(RestrrError.unknown, '');
  }

  CompiledRoute compile({List<String> params = const []}) {
    if (params.length != paramCount) {
      throw ArgumentError(
          'Error compiling route [$method $path}]: Incorrect amount of parameters! Expected: $paramCount, Provided: ${params.length}');
    }
    final Map<String, String> values = {};
    String compiledRoute = path;
    for (String param in params) {
      int paramStart = compiledRoute.indexOf('{');
      int paramEnd = compiledRoute.indexOf('}');
      values[compiledRoute.substring(paramStart + 1, paramEnd)] = param;
      compiledRoute = compiledRoute.replaceRange(paramStart, paramEnd + 1, param);
    }
    return CompiledRoute(this, compiledRoute, values);
  }
}

class CompiledRoute {
  final Route baseRoute;
  final String compiledRoute;
  final Map<String, String> parameters;
  Map<String, String>? queryParameters;

  CompiledRoute(this.baseRoute, this.compiledRoute, this.parameters, {this.queryParameters});

  CompiledRoute withQueryParams(Map<String, String> params) {
    String newRoute = compiledRoute;
    params.forEach((key, value) {
      newRoute = '$newRoute${queryParameters == null || queryParameters!.isEmpty ? '?' : '&'}$key=$value';
      queryParameters ??= {};
      queryParameters![key] = value;
    });
    return CompiledRoute(baseRoute, newRoute, parameters, queryParameters: queryParameters);
  }

  Future<Response> submit({dynamic body, String contentType = 'application/json'}) {
    if (!Restrr.hostInformation.hasHostUrl) {
      throw StateError('Host URL is not set!');
    }
    Dio dio = Dio()..interceptors.add(CookieManager(PersistCookieJar()));
    Map<String, dynamic> headers = {};
    headers['Content-Type'] = contentType;
    return dio
        .fetch(RequestOptions(
            path: compiledRoute,
            headers: headers,
            data: body,
            method: baseRoute.method.toString(),
            baseUrl: _buildBaseUrl(Restrr.hostInformation, baseRoute.isVersioned)))
        .then((value) {
      return value;
    });
  }

  String _buildBaseUrl(HostInformation hostInformation, bool isVersioned) {
    String effectiveHostUrl = hostInformation.hostUri!.toString();
    if (effectiveHostUrl.endsWith('/')) {
      effectiveHostUrl = effectiveHostUrl.substring(0, effectiveHostUrl.length - 1);
    }
    return isVersioned ? '$effectiveHostUrl/api/v${hostInformation.apiVersion}' : '$effectiveHostUrl/api';
  }
}
