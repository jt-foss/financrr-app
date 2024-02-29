import 'package:restrr/src/events/restrr_event.dart';

class RestrrEventHandler {
  final Map<Type, Function> eventMap;

  const RestrrEventHandler(this.eventMap);

  void on<T extends RestrrEvent>(Function(T) callback) {
    eventMap[T.runtimeType] = callback;
  }

  void fire<T extends RestrrEvent>(T event) {
    eventMap[event.runtimeType]?.call(event);
  }
}
