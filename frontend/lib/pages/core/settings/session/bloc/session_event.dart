part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

final class SessionUpdateEvent extends SessionEvent {
  const SessionUpdateEvent();
}
