import '../../restrr.dart';

abstract class RestrrEvent {
  final Restrr api;

  const RestrrEvent({required this.api});
}
