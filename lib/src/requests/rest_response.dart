import '../../restrr.dart';

class RestResponse<T> {
  final T? data;
  final ErrorResponse? error;

  const RestResponse({this.data, this.error});

  bool get hasData => data != null;

  static Future<RestResponse<T>> fromError<T>(Future<ErrorResponse> error) async {
    return RestResponse(error: await error);
  }
}
