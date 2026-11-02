import 'dart:async';
import 'dart:convert';

import 'package:jarina/core/api/realtime_client.dart';

/// A socket the test drives from the "server" side.
class FakeSocket implements RealtimeSocket {
  FakeSocket(this.headers);
  final Map<String, String> headers;
  final sent = <Map<String, Object?>>[];
  final _in = StreamController<String>();
  int? _code;
  bool closedByClient = false;

  void push(Map<String, Object?> msg) => _in.add(jsonEncode(msg));
  Future<void> serverClose(int code) async {
    _code = code;
    await _in.close();
  }

  @override
  Stream<String> get messages => _in.stream;
  @override
  int? get closeCode => _code;
  @override
  void send(String text) => sent.add(jsonDecode(text) as Map<String, Object?>);
  @override
  Future<void> close() async {
    closedByClient = true;
    _code ??= 1000;
    if (!_in.isClosed) await _in.close();
  }
}
