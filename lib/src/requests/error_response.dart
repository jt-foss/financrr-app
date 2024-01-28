enum RestrrError {
  unknown;

  static RestrrError byMapping(String mapping) {
    // TODO: implement
    return RestrrError.unknown;
  }
}

class ErrorResponse {
  final RestrrError error;
  final String? message;

  const ErrorResponse(this.error, this.message);

  bool get hasMessage => message != null;

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(RestrrError.byMapping(json['error']), json['message']);
  }
}
