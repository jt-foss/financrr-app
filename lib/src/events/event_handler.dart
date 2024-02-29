import 'package:restrr/src/events/restrr_event.dart';

class RestrrEventHandler {
  final Map<Type, Function> eventMap;

  const RestrrEventHandler(this.eventMap);

  void on<T extends RestrrEvent>(Type type, Function(T) callback) {
    eventMap[type] = callback;
  }

  void fire<T extends RestrrEvent>(T event) {
    print(eventMap);
    print(event.runtimeType);
    eventMap[event.runtimeType]?.call(event);
  }
}
