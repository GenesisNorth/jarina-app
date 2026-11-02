import 'dart:async';

import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina_core/jarina_core.dart';

/// A value the server owns and announces changes to: fetched on listen,
/// fetched again whenever [topic] reports a change (or a resync), and
/// cancelled at once when nobody listens.
Stream<T> liveResource<T>(RealtimeClient realtime, String topic, Future<Result<T>> Function() fetch) {
  StreamSubscription<Map<String, Object?>>? sub;
  late final StreamController<T> out;
  var loading = false;
  var again = false;

  Future<void> load() async {
    // One fetch at a time; changes during a fetch trigger one more.
    if (loading) {
      again = true;
      return;
    }
    loading = true;
    do {
      again = false;
      final r = await fetch();
      if (out.isClosed) return;
      switch (r) {
        case Ok(:final value):
          out.add(value);
        case Err(:final failure):
          out.addError(failure);
      }
    } while (again);
    loading = false;
  }

  out = StreamController<T>(
    onListen: () {
      sub = realtime.topic(topic).listen((_) => unawaited(load()), onError: (Object _) {});
      unawaited(load());
    },
    onCancel: () => sub?.cancel(),
  );
  return out.stream;
}
