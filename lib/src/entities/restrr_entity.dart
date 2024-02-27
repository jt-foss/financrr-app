import '../../restrr.dart';

typedef ID = int;

/// The base class for all Restrr entities.
/// This simply provides a reference to the Restrr instance.
abstract class RestrrEntity {
  /// A reference to the Restrr instance.
  Restrr get api;

  ID get id;
}

class RestrrEntityImpl implements RestrrEntity {
  @override
  final Restrr api;
  @override
  final ID id;

  const RestrrEntityImpl({
    required this.api,
    required this.id,
  });
}
