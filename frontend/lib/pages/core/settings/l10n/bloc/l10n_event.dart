part of 'l10n_bloc.dart';

sealed class L10nEvent extends Equatable {
  const L10nEvent();
}

sealed class L10nDataChanged extends L10nEvent {
  final String? decimalSeparator;
  final String? thousandSeparator;
  final String? dateTimeFormat;

  const L10nDataChanged({this.decimalSeparator, this.thousandSeparator, this.dateTimeFormat});

  @override
  List<Object?> get props => [decimalSeparator, thousandSeparator, dateTimeFormat];
}

class L10nDecimalSeparatorChanged extends L10nDataChanged {
  const L10nDecimalSeparatorChanged(String decimalSeparator) : super(decimalSeparator: decimalSeparator);
}

class L10nThousandSeparatorChanged extends L10nDataChanged {
  const L10nThousandSeparatorChanged(String thousandSeparator) : super(thousandSeparator: thousandSeparator);
}

class L10nDateTimeFormatChanged extends L10nDataChanged {
  const L10nDateTimeFormatChanged(String dateTimeFormat) : super(dateTimeFormat: dateTimeFormat);
}
