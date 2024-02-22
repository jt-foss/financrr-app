import '../../../restrr.dart';

/// Represents a response from a REST request.
/// This can either hold data, [T], or an [ErrorResponse].
class RestResponse<T> {
  final T? data;
  final RestrrError? error;

  const RestResponse({this.data, this.error});

  bool get hasData => data != null;
  bool get hasError => error != null;
}
