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

  static Listener registerEvent(
      String eventName, Object context, void Function(Event, Object) callback) {
    return EventBus.getInstance().on(eventName, context, callback);
  }

  static void unregisterEvent(Listener l) {
    if (l != null) {
      EventBus.getInstance().off(l);
    }
  }
}
