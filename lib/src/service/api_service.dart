import 'package:dio/dio.dart';
import 'package:restrr/restrr.dart';

abstract class ApiService {
  final Restrr api;

  const ApiService({required this.api});

  /// Tries to execute a request, using the [CompiledRoute] and maps the received data using the
  /// specified [mapper] function, ultimately returning the entity in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response = await route.submit(body: body, contentType: contentType);
      return RestResponse(data: mapper.call(response.data));
    } on DioException catch (e) {
      return _handleDioException(e, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute], without expecting any response.
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
      dynamic body,
      Map<int, RestrrError> errorMap = const {},
      String contentType = 'application/json'}) async {
    try {
      await route.submit(body: body, contentType: contentType);
      return const RestResponse(data: true);
    } on DioException catch (e) {
      return _handleDioException(e, errorMap);
    }
  }

  /// Tries to execute a request, using the [CompiledRoute] and maps the received list of data using the
  /// specified [mapper] function, ultimately returning the list of entities in an [RestResponse].
  ///
  /// If this fails, this will return an [RestResponse] containing an error.
  static Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
      required T Function(dynamic) mapper,
      Map<int, RestrrError> errorMap = const {},
      Function(String)? fullRequest,
      dynamic body,
      String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response = await route.submit(body: body, contentType: contentType);
      if (response.data is! List<dynamic>) {
        throw StateError('Received response is not a list!');
      }
      fullRequest?.call(response.data.toString());
      return RestResponse(data: (response.data as List<dynamic>).map((single) => mapper.call(single)).toList());
    } on DioException catch (e) {
      return _handleDioException(e, errorMap);
    }
  }

  static Future<RestResponse<T>> _handleDioException<T>(DioException ex, Map<int, RestrrError> errorMap) async {
    // check internet connection
    if (!await IOUtils.checkConnection()) {
      return RestrrError.noInternetConnection.toRestResponse();
    }
    // check status code
    final int? statusCode = ex.response?.statusCode;
    if (statusCode != null) {
      if (errorMap.containsKey(statusCode)) {
        return errorMap[statusCode]!.toRestResponse();
      }
      final RestrrError? err = switch (statusCode) {
        400 => RestrrError.badRequest,
        500 => RestrrError.internalServerError,
        503 => RestrrError.serviceUnavailable,
        _ => null
      };
      if (err != null) {
        return err.toRestResponse();
      }
    }
    // check timeout
    if (ex.type == DioExceptionType.connectionTimeout || ex.type == DioExceptionType.receiveTimeout) {
      return RestrrError.serverUnreachable.toRestResponse();
    }
    Restrr.log.warning('Unknown error occurred: ${ex.message}, ${ex.stackTrace}');
    return RestrrError.unknown.toRestResponse();
  }
}
