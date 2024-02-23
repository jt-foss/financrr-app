import 'package:restrr/restrr.dart';

/// Defines how to build entities from JSON responses.
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

  User buildUser(Map<String, dynamic> json) {
    return UserImpl(
      api: api,
      id: json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['display_name'],
      createdAt: DateTime.parse(json['created_at']),
      isAdmin: json['is_admin'],
    );
  }
}
