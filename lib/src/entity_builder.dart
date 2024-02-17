import 'package:restrr/restrr.dart';

class EntityBuilder {
  final RestrrImpl api;

  const EntityBuilder({required this.api});

  static HealthResponse buildHealthResponse(Map<String, dynamic> json) {
    return HealthResponseImpl(
      healthy: json['healthy'],
      apiVersion: json['api_version'],
      details: json.keys.contains('details') ? json['details'] : null,
    );
  }
}
