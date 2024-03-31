import 'package:financrr_frontend/data/repositories.dart';

class SessionRepository extends SecureStringRepository {
  const SessionRepository({required super.storage});

  @override
  String get key => 'sessionToken';
}

class SessionService {
  const SessionService._();

  static Future<bool> hasSession() => Repositories.sessionRepository.exists();
}
