import 'package:restrr/restrr.dart';

class CacheService {
  static final DefaultEntityCacheStrategy<Account, AccountId> accountCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<Transaction, TransactionId> transactionCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<User, UserId> userCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<PartialSession, PartialSessionId> sessionCache = DefaultEntityCacheStrategy();
  static final DefaultEntityCacheStrategy<Currency, CurrencyId> currencyCache = DefaultEntityCacheStrategy();
}
