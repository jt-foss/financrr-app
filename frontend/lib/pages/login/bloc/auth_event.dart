part of 'auth_bloc.dart';

@immutable
sealed class AuthenticationEvent {
  const AuthenticationEvent();
}

final class AuthenticationLoginRequested extends AuthenticationEvent {
  final Uri uri;
  final String username;
  final String password;

  const AuthenticationLoginRequested({required this.uri, required this.username, required this.password});
}

final class AuthenticationRecoveryRequested extends AuthenticationEvent {
  const AuthenticationRecoveryRequested();
}

final class AuthenticationLogoutRequested extends AuthenticationEvent {
  final Restrr api;

  const AuthenticationLogoutRequested({required this.api});
}
