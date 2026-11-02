import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina_core/jarina_core.dart';

/// The parts of a WebSocket the client uses, so tests can stand in a fake.
abstract interface class RealtimeSocket {
  Stream<String> get messages;
  int? get closeCode;
  void send(String text);
  Future<void> close();
}

typedef RealtimeConnector = Future<RealtimeSocket> Function(Uri url, Map<String, String> headers);

/// Close codes from the server (`realtime.gateway.ts`).
abstract final class RealtimeClose {
  static const tokenExpired = 4001;
  static const sessionEnded = 4002;
  static const unauthorized = 4401;
}

/// The server's shared topics; user topics (`balances`, `activity`, …) always flow.
const _sharedTopics = {'quotes'};

/// One WebSocket to `/v1/ws` for the whole app.
///
/// It opens while anything listens to a topic and closes when nothing does.
/// Dropped connections come back with backoff and resume from the last
/// event seen; an expired token is refreshed first (code 4001); a session
/// the server ended signs the user out (4002).
class RealtimeClient {
  RealtimeClient({
    required this.url,
    required this.api,
    required this.store,
    required this.headers,
    RealtimeConnector? connect,
    Duration Function(int attempt)? backoff,
  }) : _connect = connect ?? _ioConnect,
       _backoff = backoff ?? _defaultBackoff;

  final Uri url;
  final ApiClient api;
  final SessionStore store;
  final Map<String, String> Function() headers;
  final RealtimeConnector _connect;
  final Duration Function(int attempt) _backoff;

  final _topics = <String, StreamController<Map<String, Object?>>>{};
  RealtimeSocket? _socket;
  bool _running = false;
  int _lastSeq = 0;

  /// Messages on [topic]: `{type:"quotes", quotes, at}` for `quotes`,
  /// `{type:"event", seq, topic, event, data, at}` otherwise, and
  /// `{type:"resync"}` when missed events can't be replayed (refetch).
  Stream<Map<String, Object?>> topic(String topic) {
    final controller = _topics.putIfAbsent(
      topic,
      () => StreamController<Map<String, Object?>>.broadcast(
        onListen: () {
          if (_sharedTopics.contains(topic)) {
            _send({
              'op': 'subscribe',
              'topics': [topic],
            });
          }
          unawaited(_start());
        },
        onCancel: _maybeStop,
      ),
    );
    return controller.stream;
  }

  bool get _wanted => _topics.values.any((c) => c.hasListener);

  Future<void> _start() async {
    if (_running) return;
    _running = true;
    var attempt = 0;
    while (_running && _wanted) {
      final access = (await store.readTokens())?.access;
      if (access == null) break;
      RealtimeSocket socket;
      try {
        socket = await _connect(url, {...headers(), 'authorization': 'Bearer $access'});
      } on Object {
        // Refused at the upgrade (often an expired token) or no network.
        if (attempt == 0 && (await api.refreshSession()) is Err) break;
        await Future<void>.delayed(_backoff(++attempt));
        continue;
      }
      _socket = socket;
      final shared = _topics.entries
          .where((e) => _sharedTopics.contains(e.key) && e.value.hasListener)
          .map((e) => e.key);
      if (shared.isNotEmpty) socket.send(jsonEncode({'op': 'subscribe', 'topics': shared.toList()}));
      if (_lastSeq > 0) socket.send(jsonEncode({'op': 'resume', 'after': _lastSeq}));

      await for (final text in socket.messages) {
        attempt = 0;
        _dispatch(text);
      }
      _socket = null;

      switch (socket.closeCode) {
        case RealtimeClose.tokenExpired:
          if ((await api.refreshSession()) is Err) _running = false;
        case RealtimeClose.sessionEnded || RealtimeClose.unauthorized:
          _running = false;
          await api.sessionEnded();
        default:
          if (_running && _wanted) await Future<void>.delayed(_backoff(++attempt));
      }
    }
    _running = false;
  }

  void _dispatch(String text) {
    final Map<String, Object?> msg;
    try {
      msg = jsonDecode(text) as Map<String, Object?>;
    } on FormatException {
      return;
    }
    switch (msg['type']) {
      case 'hello':
        // A fresh start: only what happens from now on.
        if (_lastSeq == 0) _lastSeq = msg['seq'] as int? ?? 0;
      case 'quotes':
        _topics['quotes']?.add(msg);
      case 'event':
        final seq = msg['seq'] as int? ?? 0;
        // At-least-once delivery: drop what was already seen.
        if (seq <= _lastSeq) return;
        _lastSeq = seq;
        _topics[msg['topic']]?.add(msg);
      case 'resync':
        for (final e in _topics.entries) {
          if (!_sharedTopics.contains(e.key)) e.value.add(msg);
        }
    }
  }

  void _send(Map<String, Object?> msg) => _socket?.send(jsonEncode(msg));

  void _maybeStop() {
    if (_wanted) return;
    _running = false;
    unawaited(_socket?.close());
  }

  Future<void> dispose() async {
    _running = false;
    await _socket?.close();
    for (final c in _topics.values) {
      await c.close();
    }
  }
}

Duration _defaultBackoff(int attempt) {
  final capped = min(30, pow(2, min(attempt, 5)).toInt());
  return Duration(milliseconds: capped * 1000 ~/ 2 + Random().nextInt(capped * 500 + 1));
}

Future<RealtimeSocket> _ioConnect(Uri url, Map<String, String> headers) async {
  final ws = await WebSocket.connect(url.toString(), headers: headers);
  ws.pingInterval = const Duration(seconds: 25);
  return _IoSocket(ws);
}

class _IoSocket implements RealtimeSocket {
  _IoSocket(this._ws);
  final WebSocket _ws;

  @override
  Stream<String> get messages => _ws.where((m) => m is String).cast<String>().handleError((Object _) {});

  @override
  int? get closeCode => _ws.closeCode;

  @override
  void send(String text) => _ws.add(text);

  @override
  Future<void> close() => _ws.close();
}
