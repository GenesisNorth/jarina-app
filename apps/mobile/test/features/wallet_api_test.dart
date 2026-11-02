import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/activity/data/http_activity_repository.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/wallets/data/http_wallet_repository.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina_core/jarina_core.dart';

import '../fake_socket.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStore store;
  late List<FakeSocket> sockets;
  late List<http.Request> requests;
  late Map<String, Object?> Function(http.Request) respond;
  late ApiClient api;
  late RealtimeClient realtime;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
    await store.saveTokens(
      AuthSession.fromJson(const {
        'accessToken': 'a',
        'refreshToken': 'r',
        'userId': 'u',
        'onboarded': true,
        'twofaEnabled': true,
      }),
    );
    sockets = [];
    requests = [];
    api = ApiClient(
      baseUrl: Uri.parse('http://api.test/'),
      client: MockClient((req) async {
        requests.add(req);
        return http.Response(jsonEncode(respond(req)), 200, headers: {'content-type': 'application/json'});
      }),
      store: store,
      headers: () => {'x-device-id': 'device-0123456789abcdef'},
      onSessionEnded: () async {},
    );
    realtime = RealtimeClient(
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
  });

  HttpWalletRepository wallet() =>
      HttpWalletRepository(api, realtime, FakeLedger(latency: Duration.zero, tick: Duration.zero));

  test('balances: a snapshot, then a refetch whenever the server announces a change', () async {
    var ngn = '0.00';
    respond = (_) => {
      'fiat': {'NGN': ngn, 'GHS': '12.50'},
      'holdings': {'BTC': '0.00420000'},
      'held': <String, Object?>{},
    };
    final got = <Balances>[];
    final sub = wallet().watchBalances().listen(got.add);
    await pumpEventQueue();
    expect(got.single.fiatOf(Currency.ngn), Money.parse('0', Currency.ngn));
    expect(got.single.fiatOf(Currency.ghs), Money.parse('12.5', Currency.ghs));
    expect(got.single.qtyOf('BTC'), Decimal.parse('0.0042'));

    ngn = '15000.75';
    sockets.single.push({
      'type': 'event',
      'seq': 1,
      'topic': 'balances',
      'event': 'balance.changed',
      'data': <String, Object?>{},
    });
    await pumpEventQueue();
    expect(got.last.fiatOf(Currency.ngn), Money.parse('15000.75', Currency.ngn));
    await sub.cancel();
  });

  test('funding account, rates, and the dev deposit go to their endpoints', () async {
    respond = (req) => switch (req.url.path) {
      '/funding-accounts/NGN' => {
        'currency': 'NGN',
        'accountNumber': '5000000001',
        'accountName': 'JAR-Aminu Bello',
        'bankName': 'Moniepoint',
      },
      '/fx' => {
        'base': 'NGN',
        'rates': {
          'GHS': {'perNgn': '0.0075', 'source': 'manual', 'asOf': 'x', 'stale': false},
        },
      },
      _ => {'reference': 'SBX-1', 'inboxId': 'i'},
    };
    final repo = wallet();
    expect((await repo.fundingAccount(Currency.ngn)).valueOrNull?.accountNumber, '5000000001');
    final fx = await repo.rates();
    expect(fx.convert(Money.parse('1000', Currency.ngn), Currency.ghs), Money.parse('7.5', Currency.ghs));
    final dep = await repo.simulateDeposit(Money.parse('2500', Currency.ngn));
    expect(dep.valueOrNull?.status, TxStatus.pending);
    expect(jsonDecode(requests.last.body), {'asset': 'NGN', 'amount': '2500'});
  });

  test('activity rows keep the server’s localised titles and signs', () async {
    respond = (_) => {
      'items': [
        {
          'id': '261234567890123',
          'receiptId': '261234567890123',
          'category': 'transfers',
          'kind': 'deposit',
          'title': 'Ajiya · Tura ta banki',
          'subtitle': 'Daga MUSA IBRAHIM',
          'amount': {'amount': '15000.75', 'currency': 'NGN'},
          'createdAt': '2026-10-31T13:20:05.000Z',
          'status': 'successful',
          'description': null,
        },
        {
          'id': '261234567890124',
          'receiptId': '261234567890124',
          'category': 'transfers',
          'kind': 'conversion',
          'title': 'An canza NGN zuwa GHS',
          'subtitle': 'Canjin kuɗi',
          'amount': {'amount': '-10000.00', 'currency': 'NGN'},
          'createdAt': '2026-10-31T13:21:00.000Z',
          'status': 'successful',
          'description': null,
        },
      ],
      'nextCursor': null,
    };
    final items = await HttpActivityRepository(api, realtime).watch().first;
    expect(items.map((t) => (t.kind, t.title, t.isCredit)), [
      (TxKind.deposit, 'Ajiya · Tura ta banki', true),
      (TxKind.conversion, 'An canza NGN zuwa GHS', false),
    ]);
    expect(items.first.formattedId, '261 234 567 890 123');
  });
}
