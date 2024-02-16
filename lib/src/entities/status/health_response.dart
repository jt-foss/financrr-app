abstract class HealthResponse {
  bool get healthy;
  List<int> get supportedApiVersions;
  String get details;
}

class HealthResponseImpl implements HealthResponse {
  @override
  final bool healthy;
  @override
  final List<int> supportedApiVersions;
  @override
  final String details;

  const HealthResponseImpl({
    required this.healthy,
    required this.supportedApiVersions,
    required this.details,
  });
}
