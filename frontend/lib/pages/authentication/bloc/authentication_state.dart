part of 'authentication_bloc.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final Restrr? api;

  const AuthenticationState._({this.status = AuthenticationStatus.unknown, this.api});

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(Restrr api) : this._(status: AuthenticationStatus.authenticated, api: api);

  const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, api];
}
