import '../../restrr.dart';

/// The base class for all Restrr entities.
/// This simply provides a reference to the Restrr instance.
abstract class RestrrEntity {
  /// A reference to the Restrr instance.
  Restrr get api;
}

class RestrrEntityImpl implements RestrrEntity {
  @override
  final Restrr api;

  const RestrrEntityImpl({
    required this.api,
  });
}
