import 'package:restrr/restrr.dart';

/// Represents an error response from a REST request.
class ErrorResponse {
  final RestrrError type;
  final String? message;

  const ErrorResponse(this.type, this.message);

  bool get hasMessage => message != null;

  static fromJson(Map<String, dynamic> json) {
    return ErrorResponse(RestrrError.byMapping(json['error']), json['message']);
  }
}

/// Represents a type of error that can occur during a REST request.
enum RestrrError {
  invalidCredentials,

  /* Client errors */

  noInternetConnection(clientError: true),
  serverUnreachable(clientError: true),
  invalidUri(clientError: true),
  unknown(clientError: true);

  final bool clientError;

  const RestrrError({this.clientError = false});

  RestResponse<T> toRestResponse<T>() {
    return RestResponse(error: toErrorResponse());
  }

  ErrorResponse toErrorResponse([String? message]) {
    return ErrorResponse(this, message);
  }

  static RestrrError byMapping(String? mapping) {
    if (mapping == null) {
      return RestrrError.unknown;
    }
    // TODO: implement
    return RestrrError.unknown;
  }
}
