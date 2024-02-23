import 'package:restrr/restrr.dart';

/// Represents a type of error that can occur during a REST request.
enum RestrrError {
  /* Request errors */
  badRequest,

  /* Server errors */

  notFound,
  notSignedIn,
  invalidCredentials,
  alreadySignedIn,
  internalServerError,
  serviceUnavailable,

  /* Client errors */

  noInternetConnection(clientError: true),
  serverUnreachable(clientError: true),
  invalidUri(clientError: true),
  unknown(clientError: true);

  final bool clientError;

  const RestrrError({this.clientError = false});

  RestResponse<T> toRestResponse<T>() => RestResponse(error: this);
}
