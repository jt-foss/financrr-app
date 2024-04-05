import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc() : super(SessionInitial()) {
    on<SessionUpdateEvent>(_onSessionUpdateEvent);
  }

  void _onSessionUpdateEvent(SessionUpdateEvent event, Emitter<SessionState> emit) => emit(SessionUpdateSuccess());
}
