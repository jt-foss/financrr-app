import 'package:financrr_frontend/data/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'repository_event.dart';
part 'repository_state.dart';

class RepositoryBloc extends Bloc<RepositoryEvent, RepositoryState> {
  static final RepositoryBloc _instance = RepositoryBloc._();

  factory RepositoryBloc() => _instance;

  RepositoryBloc._() : super(RepositoryInitial()) {
    on<RepositoryWriteEvent>(_onRepositoryWriteEvent);
  }

  void write<T>(RepositoryKey<T> key, T value) async => add(RepositoryWriteEvent(key, value));

  void _onRepositoryWriteEvent(RepositoryWriteEvent event, Emitter<RepositoryState> emit) async {
    await Repository().write(event.key, event.value);
    emit(RepositoryInitial());
  }
}
