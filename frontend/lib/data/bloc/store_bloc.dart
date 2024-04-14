import 'package:financrr_frontend/data/store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  static final StoreBloc _instance = StoreBloc._();

  factory StoreBloc() => _instance;

  StoreBloc._() : super(StoreInitial()) {
    on<StoreWriteEvent>(_onStoreWriteEvent);
  }

  void write<T>(StoreKey<T> key, T value) async => add(StoreWriteEvent(key, value));

  void _onStoreWriteEvent(StoreWriteEvent event, Emitter<StoreState> emit) async {
    await KeyValueStore().write(event.key, event.value);
    emit(StoreInitial());
  }
}
