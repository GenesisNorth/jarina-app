import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/markets/data/http_market_repository.dart';

import '../fake_socket.dart';

Map<String, Object?> session(String n) => {
  'accessToken': 'access-$n',
  'refreshToken': 'refresh-$n',
  'userId': 'u',
  'onboarded': true,
  'twofaEnabled': true,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStore store;
  late List<FakeSocket> sockets;
  late int ended;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request) server;

  RealtimeClient client() {
    final api = ApiClient(
      baseUrl: Uri.parse('http://api.test/'),
      client: MockClient((req) {
        requests.add(req);
        return server(req);
      }),
      store: store,
      headers: () => {'x-device-id': 'device-0123456789abcdef'},
      onSessionEnded: () async {
        ended++;
        await store.clear();
      },
    );
    return RealtimeClient(
      url: Uri.parse('ws://api.test/v1/ws'),
      api: api,
      store: store,
      headers: api.headers,
      backoff: (_) => Duration.zero,
      connect: (url, headers) async {
        final s = FakeSocket(headers);
        sockets.add(s);
        return s;
      },
    );
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
    await store.saveTokens(AuthSession.fromJson(session('1')));
    sockets = [];
    ended = 0;
    requests = [];
    server = (_) async => http.Response('{}', 200);
  });

  test('connects when listened to, subscribes to quotes, and closes when nobody listens', () async {
    final rt = client();
    final got = <Map<String, Object?>>[];
    final sub = rt.topic('quotes').listen(got.add);
    await pumpEventQueue();

    expect(sockets.single.headers, containsPair('authorization', 'Bearer access-1'));
    expect(sockets.single.headers, containsPair('x-device-id', 'device-0123456789abcdef'));
    expect(
      sockets.single.sent,
      contains(
        equals({
          'op': 'subscribe',
          'topics': ['quotes'],
        }),
      ),
    );

    sockets.single.push({
      'type': 'quotes',
      'quotes': {'BTC': <String, Object?>{}},
      'at': 'now',
    });
    await pumpEventQueue();
    expect(got.single['type'], 'quotes');

    await sub.cancel();
    await pumpEventQueue();
    expect(sockets.single.closedByClient, isTrue);
  });

  test('drops repeated events and resumes from the last one after a drop', () async {
    final rt = client();
    final got = <int>[];
    final sub = rt.topic('balances').listen((m) => got.add(m['seq']! as int));
    await pumpEventQueue();
    final first = sockets.single
      ..push({'type': 'hello', 'seq': 10})
      ..push({'type': 'event', 'seq': 11, 'topic': 'balances', 'event': 'balance.changed', 'data': {}})
      ..push({'type': 'event', 'seq': 11, 'topic': 'balances', 'event': 'balance.changed', 'data': {}})
      ..push({'type': 'event', 'seq': 12, 'topic': 'activity', 'event': 'x', 'data': {}});
    await pumpEventQueue();
    expect(got, [11]);

    await first.serverClose(1006);
    await pumpEventQueue();
    expect(sockets, hasLength(2));
    expect(sockets.last.sent, contains(equals({'op': 'resume', 'after': 12})));
    await sub.cancel();
  });

  test('an expired token is refreshed, then the socket reconnects with the new one', () async {
    server = (req) async => req.url.path == '/auth/refresh'
        ? http.Response(jsonEncode(session('2')), 200, headers: {'content-type': 'application/json'})
        : http.Response('{}', 200);
    final rt = client();
    final sub = rt.topic('quotes').listen((_) {});
    await pumpEventQueue();
    await sockets.single.serverClose(RealtimeClose.tokenExpired);
    await pumpEventQueue();

    expect(requests.single.url.path, '/auth/refresh');
    expect(sockets.last.headers['authorization'], 'Bearer access-2');
    await sub.cancel();
  });

  test('a session ended on the server signs out and stops reconnecting', () async {
    final rt = client();
    final sub = rt.topic('quotes').listen((_) {});
    await pumpEventQueue();
    await sockets.single.serverClose(RealtimeClose.sessionEnded);
    await pumpEventQueue();
    expect(ended, 1);
    expect(sockets, hasLength(1));
    expect(await store.readTokens(), isNull);
    await sub.cancel();
  });

  test('HttpMarketRepository: snapshot first, then pushed prices', () async {
    Map<String, Object?> quote(String price) => {
      'id': 'BTC',
      'price': price,
      'open': '105047654.00',
      'changePct': 1.08,
      'intraday': [1.0, 2.0],
      'asOf': 'now',
      'source': 'quidax',
      'delayed': false,
      'stale': false,
    };
    server = (req) async => http.Response(
      jsonEncode({
        'quotes': {'BTC': quote('106180026.00')},
        'markets': <String, Object?>{},
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
    final rt = client();
    final repo = HttpMarketRepository(
      ApiClient(
        baseUrl: Uri.parse('http://api.test/'),
        client: MockClient(server),
        store: store,
        headers: () => {'x-device-id': 'device-0123456789abcdef'},
        onSessionEnded: () async {},
      ),
      rt,
    );
    final got = <String>[];
    final sub = repo.watchQuotes().listen((q) => got.add(q['BTC']!.price.toString()));
    await pumpEventQueue();
    sockets.single.push({
      'type': 'quotes',
      'quotes': {'BTC': quote('106200000.50')},
      'at': 'now',
    });
    await pumpEventQueue();
    expect(got, ['106180026', '106200000.5']);
    await sub.cancel();
  });
}
