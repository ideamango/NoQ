import 'package:eventify/eventify.dart';

class EventBus extends EventEmitter {
  static EventBus _ev;

  static EventBus getInstance() {
    if (_ev == null) {
      _ev = new EventBus();
    }
    return _ev;
  }

  static void fireEvent(String eventName, Object sender, Object eventArgs) {
    EventBus.getInstance().emit(eventName, sender, eventArgs);
  }

  static void registerEvent(
      String eventName, Object context, void Function(Event, Object) callback) {
    EventBus.getInstance().on(eventName, context, callback);
  }
}
