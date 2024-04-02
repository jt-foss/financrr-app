import 'package:financrr_frontend/data/l10n_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

part 'l10n_event.dart';
part 'l10n_state.dart';

class L10nBloc extends Bloc<L10nEvent, L10nState> {
  L10nBloc(String decimalSeparator, String thousandSeparator, DateFormat dateTimeFormat)
      : super(L10nState(
            decimalSeparator: decimalSeparator, thousandSeparator: thousandSeparator, dateTimeFormat: dateTimeFormat)) {
    on<L10nDataChanged>(_onL10nDataChanged);
  }

  void _onL10nDataChanged(L10nDataChanged event, Emitter<L10nState> emit) async {
    await L10nService.setL10nPreferences(
        decimalSeparator: event.decimalSeparator,
        thousandSeparator: event.thousandSeparator,
        dateTimeFormat: event.dateTimeFormat);
    emit(L10nState(
        decimalSeparator: event.decimalSeparator ?? state.decimalSeparator,
        thousandSeparator: event.thousandSeparator ?? state.thousandSeparator,
        dateTimeFormat: event.dateTimeFormat == null ? state.dateTimeFormat : DateFormat(event.dateTimeFormat)));
  }
}
