import 'package:dio/dio.dart';
import 'package:restrr/restrr.dart';

abstract class ApiService {
  final Restrr api;

  const ApiService({required this.api});

  // TODO: implement
  String get bearerToken => 'TODO';

  /// Tries to execute a request, using the [CompiledRoute] and maps the received data using the
  /// specified [mapper] function, ultimately returning the entity in an [ApiResponse].
  ///
  /// If this fails, this will return an [ApiResponse] containing an error.
  static Future<RestResponse<T>> request<T>(
      {required CompiledRoute route,
        required T Function(dynamic) mapper,
        String? bearerToken,
        String? mfaCode,
        dynamic body,
        String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response =
      await route.submit(bearerToken: bearerToken, mfaCode: mfaCode, body: body, contentType: contentType);
      return RestResponse(data: mapper.call(response.data));
    } on DioException catch (e) {
      return RestResponse.fromError(Route.asErrorResponse(e));
    }
  }

  /// Tries to execute a request, using the [CompiledRoute], without expecting any response.
  ///
  /// If this fails, this will return an [ApiResponse] containing an error.
  static Future<RestResponse<bool>> noResponseRequest<T>(
      {required CompiledRoute route,
        String? bearerToken,
        String? mfaCode,
        dynamic body,
        String contentType = 'application/json'}) async {
    try {
      await route.submit(bearerToken: bearerToken, mfaCode: mfaCode, body: body, contentType: contentType);
      return const RestResponse(data: true);
    } on DioException catch (e) {
      return RestResponse.fromError(Route.asErrorResponse(e));
    }
  }

  /// Tries to execute a request, using the [CompiledRoute] and maps the received list of data using the
  /// specified [mapper] function, ultimately returning the list of entities in an [ApiResponse].
  ///
  /// If this fails, this will return an [ApiResponse] containing an error.
  static Future<RestResponse<List<T>>> multiRequest<T>(
      {required CompiledRoute route,
        required T Function(dynamic) mapper,
        Function(String)? fullRequest,
        String? bearerToken,
        String? mfaCode,
        dynamic body,
        String contentType = 'application/json'}) async {
    try {
      final Response<dynamic> response =
      await route.submit(bearerToken: bearerToken, mfaCode: mfaCode, body: body, contentType: contentType);
      if (response.data is! List<dynamic>) {
        throw StateError('Received response is not a list!');
      }
      fullRequest?.call(response.data.toString());
      return RestResponse(data: (response.data as List<dynamic>).map((single) => mapper.call(single)).toList());
    } on DioException catch (e) {
      return RestResponse.fromError(Route.asErrorResponse(e));
    }
  }
}