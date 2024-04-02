part of 'l10n_bloc.dart';

class L10nState extends Equatable {
  final String decimalSeparator;
  final String thousandSeparator;
  final DateFormat dateTimeFormat;

  const L10nState({required this.decimalSeparator, required this.thousandSeparator, required this.dateTimeFormat});

  @override
  List<Object?> get props => [decimalSeparator, thousandSeparator, dateTimeFormat];
}
