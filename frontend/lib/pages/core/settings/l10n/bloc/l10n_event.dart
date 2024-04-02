part of 'l10n_bloc.dart';

sealed class L10nEvent extends Equatable {
  const L10nEvent();
}

class L10nDataChanged extends L10nEvent {
  final String? decimalSeparator;
  final String? thousandSeparator;
  final String? dateTimeFormat;

  const L10nDataChanged({this.decimalSeparator, this.thousandSeparator, this.dateTimeFormat});

  @override
  List<Object?> get props => [decimalSeparator, thousandSeparator, dateTimeFormat];
}
