part of 'store_bloc.dart';

sealed class StoreEvent {}

class StoreWriteEvent<T> extends StoreEvent {
  final StoreKey<T> key;
  final T value;

  StoreWriteEvent(this.key, this.value);
}
