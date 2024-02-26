import 'package:dio/dio.dart';
import 'package:restrr/restrr.dart';

import '../requests/route.dart';

/// Utility class for handling requests.
class RequestHandler {
  const RequestHandler._();

  /// Tries to execute a request, using the [CompiledRoute] and maps the received data using the
  /// specified [mapper] function, ultimately returning the entity in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      required RouteOptions routeOptions,
      bool isWeb = false,
      Map<int, RestrrError> errorMap = const {},
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response =
          await route.submit(routeOptions: routeOptions, body: body, isWeb: isWeb, contentType: contentType);
      return RestResponse(data: mapper.call(response.data), statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute], without expecting any response.
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
      required RouteOptions routeOptions,
      bool isWeb = false,
      dynamic body,
      Map<int, RestrrError> errorMap = const {},
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response =
          await route.submit(routeOptions: routeOptions, body: body, isWeb: isWeb, contentType: contentType);
      return RestResponse(data: true, statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute] and maps the received list of data using the
  /// specified [mapper] function, ultimately returning the list of entities in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
      required RouteOptions routeOptions,
      bool isWeb = false,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      Function(String)? fullRequest,
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response =
          await route.submit(routeOptions: routeOptions, body: body, isWeb: isWeb, contentType: contentType);
      if (response.data is! List<dynamic>) {
        throw StateError('Received response is not a list!');
      }
      fullRequest?.call(response.data.toString());
      return RestResponse(
          data: (response.data as List<dynamic>).map((single) => mapper.call(single)).toList(),
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleDioException(e, isWeb, errorMap);
    }
  }

  static Future<RestResponse<T>> _handleDioException<T>(
      DioException ex, bool isWeb, Map<int, RestrrError> errorMap) async {
    // check internet connection
    if (!isWeb && !await IOUtils.checkConnection()) {
      return RestrrError.noInternetConnection.toRestResponse();
    }
    // check status code
    final int? statusCode = ex.response?.statusCode;
    if (statusCode != null) {
      if (errorMap.containsKey(statusCode)) {
        return errorMap[statusCode]!.toRestResponse(statusCode: statusCode);
      }
      final RestrrError? err = switch (statusCode) {
        400 => RestrrError.badRequest,
        500 => RestrrError.internalServerError,
        503 => RestrrError.serviceUnavailable,
        _ => null
      };
      if (err != null) {
        return err.toRestResponse(statusCode: statusCode);
      }
    }
    // check timeout
    if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout) {
      return RestrrError.serverUnreachable.toRestResponse(statusCode: statusCode);
    }
    Restrr.log.warning('Unknown error occurred: ${ex.message}, ${ex.stackTrace}');
    return RestrrError.unknown.toRestResponse(statusCode: statusCode);
  }
}

/// A service that provides methods to interact with the API.
abstract class ApiService {
  final Restrr api;

  const ApiService({required this.api});

  Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      dynamic body,
      String contentType = 'application/json'}) async {
    return RequestHandler.request(
        route: route,
        routeOptions: api.routeOptions,
        isWeb: api.options.isWeb,
        mapper: mapper,
        errorMap: errorMap,
        body: body,
        contentType: contentType);
  }

  Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
      dynamic body,
      Map<int, RestrrError> errorMap = const {},
      String contentType = 'application/json'}) async {
    return RequestHandler.noResponseRequest(
        route: route,
        routeOptions: api.routeOptions,
        isWeb: api.options.isWeb,
        body: body,
        errorMap: errorMap,
        contentType: contentType);
  }

  Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      Function(String)? fullRequest,
      dynamic body,
      String contentType = 'application/json'}) async {
    return RequestHandler.multiRequest(
        route: route,
        routeOptions: api.routeOptions,
        isWeb: api.options.isWeb,
        mapper: mapper,
        errorMap: errorMap,
        fullRequest: fullRequest,
        body: body,
        contentType: contentType);
  }
}
