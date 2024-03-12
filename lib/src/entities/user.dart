import '../../restrr.dart';

abstract class User extends RestrrEntity {
  String get username;
  String? get email;
  String? get displayName;
  DateTime get createdAt;
  bool get isAdmin;

  /// Returns the effective display name for the user.
  /// If the display name is not set, the username is returned instead.
  String get effectiveDisplayName;
}

class UserImpl extends RestrrEntityImpl implements User {
  @override
  final String username;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final DateTime createdAt;
  @override
  final bool isAdmin;

  const UserImpl({
    required super.api,
    required super.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.isAdmin,
  });

  @override
  String get effectiveDisplayName => displayName ?? username;
}
