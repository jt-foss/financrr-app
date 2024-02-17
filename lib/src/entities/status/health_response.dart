abstract class HealthResponse {
  bool get healthy;
  int get apiVersion;
  String? get details;
}

class HealthResponseImpl implements HealthResponse {
  @override
  final bool healthy;
  @override
  final int apiVersion;
  @override
  final String? details;

  const HealthResponseImpl({
    required this.healthy,
    required this.apiVersion,
    required this.details,
  });
}
