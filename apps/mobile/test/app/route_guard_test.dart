import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/route_guard.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';

void main() {
  const signedOut = SessionState();
  const midKyc = SessionState(signedIn: true);
  const limited = SessionState(signedIn: true, onboarded: true);
  const full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);

  group('signed out', () {
    test('may use onboarding screens', () {
      for (final r in AppRoute.values.where((r) => r.group == RouteGroup.preAuth)) {
        expect(guardRedirect(r, signedOut), isNull, reason: r.name);
      }
    });

    test('everything else goes to welcome', () {
      expect(guardRedirect(AppRoute.home, signedOut), AppRoute.welcome.path);
      expect(guardRedirect(AppRoute.kyc1, signedOut), AppRoute.welcome.path);
      expect(guardRedirect(AppRoute.qswap, signedOut), AppRoute.welcome.path);
    });
  });

  group('signed in, KYC unfinished', () {
    test('stays inside KYC', () {
      expect(guardRedirect(AppRoute.kyc3, midKyc), isNull);
      expect(guardRedirect(AppRoute.home, midKyc), AppRoute.kyc1.path);
      expect(guardRedirect(AppRoute.welcome, midKyc), AppRoute.kyc1.path);
    });
  });

  group('onboarded without 2FA (account limited)', () {
    test('every prototype GATED screen redirects to disabled', () {
      const prototypeGated = [
        'p2p', 'entry', 'review', 'authpin', 'auth2fa', 'payconfirm', 'people', 'qswap', 'qpro', //
        'qwd', 'qcashout', 'qbuy', 'qloan', 'withdraw', 'convert', 'rule', 'bill',
      ];
      expect(AppRoute.values.where((r) => r.gated).map((r) => r.name).toSet(), prototypeGated.toSet());
      for (final name in prototypeGated) {
        expect(guardRedirect(AppRoute.byName(name), limited), '/disabled?from=$name', reason: name);
      }
    });

    test('can view balances and turn 2FA on', () {
      expect(guardRedirect(AppRoute.home, limited), isNull);
      expect(guardRedirect(AppRoute.receive, limited), isNull);
      expect(guardRedirect(AppRoute.kyc6, limited), isNull);
      expect(guardRedirect(AppRoute.disabled, limited), isNull);
    });
  });

  group('fully set up', () {
    test('gated screens open, onboarding bounces home', () {
      expect(guardRedirect(AppRoute.qswap, full), isNull);
      expect(guardRedirect(AppRoute.welcome, full), AppRoute.home.path);
      expect(guardRedirect(AppRoute.kyc2, full), AppRoute.home.path);
      expect(guardRedirect(AppRoute.disabled, full), AppRoute.home.path);
    });
  });

  test('dev index is always reachable', () {
    for (final s in [signedOut, midKyc, limited, full]) {
      expect(guardRedirect(AppRoute.dev, s), isNull);
    }
  });
}
