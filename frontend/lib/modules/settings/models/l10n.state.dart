import 'package:easy_localization/easy_localization.dart';

import '../../../shared/models/store.dart';

class L10nState {
  final String decimalSeparator;
  final String thousandSeparator;
  final DateFormat dateFormat;

  const L10nState({
    required this.decimalSeparator,
    required this.thousandSeparator,
    required this.dateFormat,
  });

  L10nState.initial()
      : decimalSeparator = StoreKey.decimalSeparator.readSync() ?? '.',
        thousandSeparator = StoreKey.thousandSeparator.readSync() ?? ',',
        dateFormat = StoreKey.dateTimeFormat.readSync()!;

  L10nState copyWith({
    String? decimalSeparator,
    String? thousandSeparator,
    DateFormat? dateFormat,
  }) {
    return L10nState(
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandSeparator: thousandSeparator ?? this.thousandSeparator,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}
