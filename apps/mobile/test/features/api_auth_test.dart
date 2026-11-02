import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/account/data/http_profile_repository.dart';
import 'package:jarina/features/auth/data/http_auth_repository.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/kyc/data/http_kyc_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/security/data/http_security_repository.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response json(Object body, [int status = 200, Map<String, String> headers = const {}]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8', ...headers});

http.Response error(int status, String code, [Map<String, Object?> details = const {}]) => json({
  'error': {'code': code, 'message': code, 'details': details},
}, status);

Map<String, Object?> session(String n) => {
  'accessToken': 'access-$n',
  'accessTokenExpiresAt': '2026-10-31T12:15:00.000Z',
  'refreshToken': 'refresh-$n',
  'userId': '0b8f7c1e-2f4f-4a52-9a0b-2b7f2a1c9d10',
  'onboarded': false,
  'twofaEnabled': false,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionStore store;
  late List<http.Request> sent;
  late int sessionsEnded;

  ApiClient client(Future<http.Response> Function(http.Request req) handler) => ApiClient(
    baseUrl: Uri.parse('http://api.test/'),
    client: MockClient((req) {
      sent.add(req);
      return handler(req);
    }),
    store: store,
    headers: () => {'x-device-id': 'device-0123456789abcdef'},
    onSessionEnded: () async {
      sessionsEnded++;
      await store.clear();
    },
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    store = SessionStore();
    sent = [];
    sessionsEnded = 0;
  });

  Future<void> signIn(String n) => store.saveTokens(AuthSession.fromJson(session(n)));

  group('HttpAuthRepository', () {
    test('sends a code and reads the challenge', () async {
      final repo = HttpAuthRepository(
        client(
          (_) async => json({
            'id': 'c1',
            'phoneE164': '+2348012345678',
            'channel': 'sms',
            'purpose': 'login',
            'resendAvailableAt': '2026-10-31T12:00:30.000Z',
            'expiresAt': '2026-10-31T12:10:00.000Z',
          }, 201),
        ),
      );
      final r = await repo.sendOtp(
        phoneE164: '+2348012345678',
        channel: OtpChannel.whatsapp,
        purpose: OtpPurpose.login,
      );

      final c = r.valueOrNull!;
      expect(c.channel, OtpChannel.sms, reason: 'WhatsApp fell back to SMS on the server');
      expect(c.purpose, OtpPurpose.login);
      expect(c.resendAvailableAt, DateTime.utc(2026, 10, 31, 12, 0, 30));
      expect(sent.single.url.toString(), 'http://api.test/auth/otp');
      expect(sent.single.headers['x-device-id'], 'device-0123456789abcdef');
      expect(sent.single.headers.containsKey('authorization'), isFalse);
      expect(jsonDecode(sent.single.body), {'phoneE164': '+2348012345678', 'channel': 'whatsapp', 'purpose': 'login'});
    });

    test('a correct code signs in or asks for 2FA', () async {
      var twofa = false;
      final repo = HttpAuthRepository(
        client(
          (_) async => json(
            twofa ? {'outcome': 'twofaRequired', 'ticket': 't' * 43} : {'outcome': 'signedIn', 'session': session('1')},
          ),
        ),
      );

      final signedIn = (await repo.verifyOtp(challengeId: 'c1', code: '123456')).valueOrNull;
      expect(signedIn, isA<SignedIn>().having((s) => s.session.accessToken, 'access', 'access-1'));

      twofa = true;
      final needs2fa = (await repo.verifyOtp(challengeId: 'c1', code: '123456')).valueOrNull;
      expect(needs2fa, isA<TwofaRequired>().having((t) => t.ticket, 'ticket', 't' * 43));
    });

    test('maps server errors to the failures screens show', () async {
      late http.Response next;
      final repo = HttpAuthRepository(client((_) async => next));
      Future<Failure?> verify() async => switch (await repo.verifyOtp(challengeId: 'c1', code: '000000')) {
        Err(:final failure) => failure,
        Ok() => null,
      };

      next = error(400, 'wrong_code', {'attemptsLeft': 3});
      expect(await verify(), isA<WrongCodeFailure>().having((f) => f.attemptsLeft, 'left', 3));
      next = error(400, 'code_expired');
      expect(await verify(), isA<CodeExpiredFailure>());
      next = error(404, 'user_not_found');
      expect(await verify(), isA<NoAccountFailure>());
      next = error(429, 'rate_limited', {'retryAfterSeconds': 900});
      expect(
        await verify(),
        isA<RateLimitedFailure>().having((f) => f.retryAfter, 'wait', const Duration(minutes: 15)),
      );
      next = http.Response('<html>bad gateway</html>', 502);
      expect(await verify(), isA<ApiFailure>().having((f) => f.code, 'code', 'internal'));
    });

    test('no connection is a network failure', () async {
      final repo = HttpAuthRepository(client((_) async => throw http.ClientException('Connection refused')));
      final r = await repo.sendOtp(phoneE164: '+2348012345678', channel: OtpChannel.whatsapp);
      expect(r, isA<Err<OtpChallenge>>().having((e) => e.failure, 'failure', isA<NetworkFailure>()));
    });
  });

  group('ApiClient sessions', () {
    test('an expired token is refreshed once for concurrent calls, then each call is retried', () async {
      await signIn('1');
      final refreshed = Completer<void>();
      var refreshes = 0;
      final api = client((req) async {
        if (req.url.path == '/auth/refresh') {
          refreshes++;
          expect(jsonDecode(req.body), {'refreshToken': 'refresh-1'});
          await refreshed.future;
          return json(session('2'));
        }
        return req.headers['authorization'] == 'Bearer access-2'
            ? json({'ok': true})
            : error(401, 'unauthenticated', {'reason': 'expired'});
      });

      final calls = [api.get('me'), api.get('me'), api.post('security/2fa/setup', signedIn: true)];
      await pumpEventQueue();
      refreshed.complete();
      final results = await Future.wait(calls);

      expect(results.every((r) => r.isOk), isTrue);
      expect(refreshes, 1);
      expect(await store.readTokens(), (access: 'access-2', refresh: 'refresh-2'));
      expect(sessionsEnded, 0);
    });

    test('a rejected refresh ends the session', () async {
      await signIn('1');
      final api = client(
        (req) async => req.url.path == '/auth/refresh'
            ? error(401, 'unauthenticated', {'reason': 'reused'})
            : error(401, 'unauthenticated', {'reason': 'expired'}),
      );

      final r = await api.get('me');
      expect(r, isA<Err<Object?>>().having((e) => e.failure, 'failure', isA<UnauthorizedFailure>()));
      expect(sessionsEnded, 1);
      expect(await store.readTokens(), isNull);
    });

    test('a refresh that fails for lack of network keeps the session', () async {
      await signIn('1');
      final api = client((req) async {
        if (req.url.path == '/auth/refresh') throw http.ClientException('offline');
        return error(401, 'unauthenticated', {'reason': 'expired'});
      });

      final r = await api.get('me');
      expect(r, isA<Err<Object?>>().having((e) => e.failure, 'failure', isA<NetworkFailure>()));
      expect(sessionsEnded, 0);
      expect(await store.readTokens(), isNotNull);
    });

    test('a session revoked on the server signs out without refreshing', () async {
      await signIn('1');
      final api = client((_) async => error(401, 'unauthenticated', {'reason': 'session'}));

      expect((await api.get('me')).isOk, isFalse);
      expect(sent.map((r) => r.url.path), ['/me']);
      expect(sessionsEnded, 1);
    });

    test('signed-in calls without tokens end the session locally', () async {
      final api = client((_) async => json({}));
      expect((await api.get('me')).isOk, isFalse);
      expect(sent, isEmpty);
      expect(sessionsEnded, 1);
    });
  });

  test('HttpKycRepository enrols 2FA through the API', () async {
    await signIn('1');
    final kyc = HttpKycRepository(
      client(
        (req) async => switch (req.url.path) {
          '/security/2fa/setup' => json({
            'secret': 'JBSWY3DPEHPK3PXP',
            'provisioningUri': 'otpauth://totp/Jarina:%2B2348012345678?secret=JBSWY3DPEHPK3PXP&issuer=Jarina',
            'backupCodes': ['ABCD2345', 'EFGH6789'],
          }),
          _ => error(400, 'wrong_code'),
        },
      ),
      FakeBackend(latency: Duration.zero),
    );

    final setup = (await kyc.startTotpSetup()).valueOrNull!;
    expect(setup.secret, 'JBSWY3DPEHPK3PXP');
    expect(setup.backupCodes, ['ABCD2345', 'EFGH6789']);
    expect(sent.single.headers['authorization'], 'Bearer access-1');

    final confirm = await kyc.confirmTotp('000000');
    expect(confirm, isA<Err<void>>().having((e) => e.failure, 'failure', isA<WrongCodeFailure>()));
  });

  group('HttpSecurityRepository', () {
    test("PIN failures map to the lock screen's failures", () async {
      await signIn('1');
      late http.Response next;
      final repo = HttpSecurityRepository(client((_) async => next));

      next = error(403, 'wrong_pin', {'attemptsLeft': 2});
      expect(
        await repo.verifyPin('583947'),
        isA<Err<String>>().having(
          (e) => e.failure,
          'f',
          isA<WrongPinFailure>().having((f) => f.attemptsLeft, 'left', 2),
        ),
      );
      next = error(403, 'pin_locked', {'lockedUntil': null, 'contactSupport': true});
      expect(
        await repo.verifyPin('583947'),
        isA<Err<String>>().having((e) => e.failure, 'f', isA<PinLockedFailure>()),
      );
      next = json({'token': 'pin-token'});
      expect((await repo.verifyPin('739462')).valueOrNull, 'pin-token');
      expect(jsonDecode(sent.last.body), {'pin': '739462'});
      expect(sent.last.headers['authorization'], 'Bearer access-1');
    });

    test('step-up tokens travel in their headers', () async {
      await signIn('1');
      late http.Response next;
      final repo = HttpSecurityRepository(client((_) async => next));

      next = http.Response('', 204);
      expect((await repo.removeDevice('d-2', pinToken: 'pt')).isOk, isTrue);
      expect(sent.last.method, 'DELETE');
      expect(sent.last.url.path, '/security/devices/d-2');
      expect(sent.last.headers['x-pin-token'], 'pt');

      next = error(403, 'step_up_required', {'level': 'pinAnd2fa'});
      final r = await repo.regenerateBackupCodes(twofaToken: 'stale');
      expect(sent.last.headers['x-2fa-token'], 'stale');
      expect(
        r,
        isA<Err<List<String>>>().having(
          (e) => e.failure,
          'f',
          isA<StepUpRequiredFailure>().having((f) => f.level, 'level', StepUpLevel.pinAnd2fa),
        ),
      );
    });

    test("reads devices and backup codes; a failed read throws for the screen's error state", () async {
      await signIn('1');
      final repo = HttpSecurityRepository(
        client(
          (req) async => switch (req.url.path) {
            '/security/devices' => json([
              {'id': 'a', 'name': 'iPhone', 'platform': 'ios', 'lastSeen': '2026-10-31T12:00:00.000Z', 'current': true},
              {
                'id': 'b',
                'name': 'Android phone',
                'platform': 'android',
                'lastSeen': '2026-10-28T09:00:00.000Z',
                'current': false,
              },
            ]),
            _ => error(500, 'internal'),
          },
        ),
      );
      final devices = await repo.trustedDevices();
      expect(devices.map((d) => (d.id, d.current)), [('a', true), ('b', false)]);
      expect(devices.last.lastSeen, DateTime.utc(2026, 10, 28, 9));
      await expectLater(repo.backupCodesLeft(), throwsA(isA<ApiFailure>()));
    });
  });

  test('HttpKycRepository sends details the way the API expects', () async {
    await signIn('1');
    late http.Response next;
    final kyc = HttpKycRepository(client((_) async => next), FakeBackend(latency: Duration.zero));

    next = http.Response('', 204);
    await kyc.submitPersonalDetails(
      PersonalDetails(
        firstName: 'Aïssatou',
        lastName: 'Ɗanjuma',
        dateOfBirth: DateTime(1990, 5, 2),
        email: 'a@b.co',
        middleName: ' ',
      ),
    );
    expect(sent.last.method, 'PUT');
    expect(jsonDecode(sent.last.body), {
      'firstName': 'Aïssatou',
      'lastName': 'Ɗanjuma',
      'dateOfBirth': '1990-05-02',
      'email': 'a@b.co',
    });

    next = error(409, 'username_taken');
    expect(
      await kyc.claimUsername('musa'),
      isA<Err<void>>().having((e) => e.failure, 'f', isA<UsernameTakenFailure>()),
    );
    next = json({'available': false});
    expect((await kyc.isUsernameAvailable('a b')).valueOrNull, isFalse);
    expect(sent.last.url.path, '/usernames/a%20b');

    next = error(400, 'validation_failed', {'field': 'pin', 'reason': 'weak_pin'});
    expect(
      await kyc.setPin('123456'),
      isA<Err<void>>().having((e) => e.failure, 'f', isA<ValidationFailure>().having((f) => f.field, 'field', 'pin')),
    );
  });

  test('HttpProfileRepository fills in what onboarding has not reached yet', () async {
    await signIn('1');
    final repo = HttpProfileRepository(
      client(
        (_) async => json({
          'userId': 'u',
          'phoneE164': '+2348012345678',
          'firstName': null,
          'lastName': null,
          'username': null,
          'tier': 1,
          'email': null,
          'custodyAccountId': null,
        }),
      ),
    );
    final me = await repo.me();
    expect((me.firstName, me.username, me.tier, me.phoneE164), ('', '', 1, '+2348012345678'));
  });

  test('the device id is stable and matches the server format', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final id = deviceId(prefs);
    expect(id, matches(RegExp(r'^[A-Za-z0-9_-]{16,128}$')));
    await pumpEventQueue();
    expect(deviceId(prefs), id);
  });
}
