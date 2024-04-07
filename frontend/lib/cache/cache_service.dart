import 'package:restrr/restrr.dart';

class CacheService {
  static final DefaultEntityCacheStrategy<Account, AccountId> accountCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<Transaction, TransactionId> transactionCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<Currency, CurrencyId> currencyCache = DefaultEntityCacheStrategy();
}
