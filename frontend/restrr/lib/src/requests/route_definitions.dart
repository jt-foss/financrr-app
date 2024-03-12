import 'package:restrr/src/requests/route.dart';

class StatusRoutes {
  const StatusRoutes._();

  static final Route health = Route.get('/status/health', isVersioned: false);
  static final Route coffee = Route.get('/status/coffee', isVersioned: false);
}

class UserRoutes {
  const UserRoutes._();

  static final Route me = Route.get('/user/@me');
  static final Route login = Route.post('/user/login');
  static final Route logout = Route.delete('/user/logout');
  static final Route register = Route.post('/user/register');
}

class CurrencyRoutes {
  const CurrencyRoutes._();

  static final Route retrieveAll = Route.get('/currency');
  static final Route create = Route.post('/currency/{currencyId}');
  static final Route retrieveById = Route.get('/currency/{currencyId}');
  static final Route deleteById = Route.delete('/currency/{currencyId}');
  static final Route updateById = Route.patch('/currency/{currencyId}');
}
