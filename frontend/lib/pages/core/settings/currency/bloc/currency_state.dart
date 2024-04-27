part of 'currency_bloc.dart';

sealed class CurrencyState {}

final class CurrencyInitial extends CurrencyState {}

final class CurrencyUpdateSuccess extends CurrencyState {}
