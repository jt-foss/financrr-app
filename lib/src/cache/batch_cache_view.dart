import '../../restrr.dart';

class RestrrEntityBatchCacheView<T extends RestrrEntity> {
  List<T>? _lastSnapshot;

  List<T>? get() => _lastSnapshot;

  void update(List<T> value) => _lastSnapshot = value;

  void clear() => _lastSnapshot = null;

  bool get hasSnapshot => _lastSnapshot != null;
}