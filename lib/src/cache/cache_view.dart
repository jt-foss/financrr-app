import 'package:restrr/restrr.dart';

class RestrrEntityCacheView<T extends RestrrEntity> {
  final Map<ID, T> _cache = {};

  T? get(ID id) => _cache[id];

  T cache(T value) => _cache[value.id] = value;

  T? remove(ID id) => _cache.remove(id);

  void clear() => _cache.clear();

  bool contains(ID id) => _cache.containsKey(id);
}
