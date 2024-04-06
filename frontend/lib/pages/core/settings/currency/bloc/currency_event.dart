part of 'currency_bloc.dart';

sealed class CurrencyEvent {
  const CurrencyEvent();
}

final class CurrencyUpdateEvent extends CurrencyEvent {
  const CurrencyUpdateEvent();
}
