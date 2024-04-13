part of 'repository_bloc.dart';

sealed class RepositoryEvent {}

class RepositoryWriteEvent<T> extends RepositoryEvent {
  final RepositoryKey<T> key;
  final T value;

  RepositoryWriteEvent(this.key, this.value);
}
