import 'package:flutter_bloc/flutter_bloc.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  CurrencyBloc() : super(CurrencyInitial()) {
    on<CurrencyUpdateEvent>(_onCurrencyUpdateEvent);
  }

  void _onCurrencyUpdateEvent(CurrencyUpdateEvent event, Emitter<CurrencyState> emit) => emit(CurrencyUpdateSuccess());
}
