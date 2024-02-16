import 'package:restrr/restrr.dart';

class EntityBuilder {
  final RestrrImpl api;

  const EntityBuilder({required this.api});

  HealthResponse buildHealthResponse(Map<String, dynamic> json) {
    return HealthResponseImpl(
      healthy: json['healthy'],
      supportedApiVersions: (json['supportedApiVersions'] as List).map((e) => e as int).toList(),
      details: json['details'],
    );
  }
}
