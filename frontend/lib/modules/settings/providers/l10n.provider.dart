import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/shared/models/store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/l10n.state.dart';

final StateNotifierProvider<L10nNotifier, L10nState> l10nProvider = StateNotifierProvider((_) => L10nNotifier());

class L10nNotifier extends StateNotifier<L10nState> {
  L10nNotifier() : super(L10nState.initial());

  void setDecimalSeparator(String separator) {
    StoreKey.decimalSeparator.write(separator);
    state = state.copyWith(decimalSeparator: separator);
  }

  void setThousandSeparator(String separator) {
    StoreKey.thousandSeparator.write(separator);
    state = state.copyWith(thousandSeparator: separator);
  }

  void setDateFormat(DateFormat format) {
    StoreKey.dateTimeFormat.write(format);
    state = state.copyWith(dateFormat: format);
  }
}
