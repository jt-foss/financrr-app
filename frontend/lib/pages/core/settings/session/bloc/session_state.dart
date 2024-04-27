part of 'session_bloc.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {}

final class SessionUpdateSuccess extends SessionState {}
