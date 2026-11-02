import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina_core/jarina_core.dart';

import '../test/flows/onboarding_flow_test.dart' show keypad, tapButton;
import '../test/helpers.dart';

/// Sign-up, every onboarding step, 2FA and login against a running local API.
///
/// ```sh
/// (cd ../../../jarina_backend && make dev)   # OTP_DEV_CODE=123456
/// flutter test integration_test/live_auth_test.dart -d DEVICE_ID
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Real network: pump real time until [done] or fail after [timeout].
  Future<void> waitFor(WidgetTester tester, bool Function() done, String what, {int seconds = 15}) async {
    for (var i = 0; i < seconds * 10; i++) {
      if (done()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('Timed out waiting for $what');
  }

  // A fresh Nigerian number per run, so the account is new.
  final national = '080${List.generate(8, (_) => Random().nextInt(10)).join()}';
  const devCode = '123456';
  const pin = '739462';

  testWidgets('a new number signs up, onboards, logs out and logs back in to Home', (tester) async {
    final c = await pumpApp(tester, env: Env.local);
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

    // Sign up: country, language, WhatsApp number, code.
    await tapButton(tester, 'Create account');
    await tester.tap(find.bySemanticsLabel('Nigeria'));
    await tester.pumpAndSettle();
    await tapButton(tester, 'Continue');
    await tester.enterText(find.byType(TextField), national);
    await tester.pump();
    await tapButton(tester, 'Send WhatsApp code');
    await waitFor(tester, () => loc() == AppRoute.otp.path, 'the code screen');

    await keypad(tester, '000000');
    await waitFor(tester, () => find.text("That code isn't right. Try again.").evaluate().isNotEmpty, 'wrong code');
    await keypad(tester, devCode);
    await waitFor(tester, () => c.read(sessionProvider).signedIn, 'sign-in');
    await waitFor(tester, () => loc() == AppRoute.kyc1.path, 'KYC step 1');

    // Step 5 · details (saved on the server).
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Aïssatou');
    await tester.enterText(fields.at(2), 'Ɗanjuma');
    await tester.enterText(fields.at(3), '12051990');
    await tester.enterText(fields.at(4), 'aissatou@example.com');
    await tester.pump();
    await tapButton(tester, 'Continue');
    await waitFor(tester, () => loc() == AppRoute.username.path, 'the username step');

    // Step 6 · a reserved name, then a free one, claimed on the server.
    await tester.enterText(find.byType(TextField), 'support');
    await waitFor(tester, () => find.text('This username is reserved').evaluate().isNotEmpty, 'reserved name refused');
    final handle = 'aissatou${national.substring(5)}';
    await tester.enterText(find.byType(TextField), handle);
    await waitFor(tester, () => find.text('@$handle is available').evaluate().isNotEmpty, 'the name check');
    await tapButton(tester, 'Claim @$handle');
    await waitFor(tester, () => loc() == AppRoute.kyc2.path, 'the ID step');

    // Steps 7–8 · ID and liveness (still the fake until Smile ID).
    await tester.enterText(find.byType(TextField), '22212345678');
    await tester.pump();
    await tapButton(tester, 'Continue');
    await waitFor(tester, () => loc() == AppRoute.kyc3.path, 'liveness');
    await tapButton(tester, 'Start camera');
    await tapButton(tester, 'Continue');
    await waitFor(tester, () => loc() == AppRoute.kyc4.path, 'the address step');

    // Step 9 · address.
    await tester.tap(find.text('Select state'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)), 'kan');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Kano')));
    await tester.pumpAndSettle();
    final addr = find.byType(TextField);
    await tester.enterText(addr.at(0), 'Kano');
    await tester.enterText(addr.at(1), 'No. 12 Zoo Road');
    await tester.pump();
    await tester.ensureVisible(find.text('Trader'));
    await tester.tap(find.text('Trader'));
    await tapButton(tester, 'Continue');
    await waitFor(tester, () => loc() == AppRoute.kyc5.path, 'the PIN step');

    // Steps 10–11 · PIN, set on the server (argon2id).
    await keypad(tester, pin);
    await keypad(tester, pin);
    await waitFor(tester, () => loc() == AppRoute.kyc6.path, 'the 2FA step');

    // Step 12 · 2FA with a real authenticator code.
    final setup = (await tester.runAsync(() => c.read(kycRepositoryProvider).startTotpSetup()))!.valueOrNull!;
    expect(setup.backupCodes, hasLength(8));
    await waitFor(tester, () => find.byType(TextField).evaluate().isNotEmpty, 'the 2FA code field');
    await tester.enterText(find.byType(TextField), Totp.code(setup.secret, DateTime.now()));
    await tester.pump();
    await tapButton(tester, 'Verify & turn on 2FA');
    await waitFor(tester, () => loc() == AppRoute.kycdone.path, 'KYC done');

    // The server agrees the account is onboarded, with what was entered.
    final me = await tester.runAsync(() => c.read(profileRepositoryProvider).me());
    expect((me!.firstName, me.lastName, me.username), ('Aïssatou', 'Ɗanjuma', handle));
    final pinOk = await tester.runAsync(() => c.read(securityRepositoryProvider).verifyPin(pin));
    expect(pinOk!.isOk, isTrue);
    expect(c.read(sessionProvider).twofaEnabled, isTrue);

    // Log out: the server ends the session.
    await tester.runAsync(() => c.read(authRepositoryProvider).logout());
    await c.read(sessionProvider.notifier).signOut();
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider).signedIn, isFalse);

    // Log in: WhatsApp code, then the authenticator (next 30 s step: the last one was used).
    c.read(routerProvider).go(AppRoute.welcome.path);
    await tester.pumpAndSettle();
    await tapButton(tester, 'Log in');
    await tester.enterText(find.byType(TextField), national);
    await tester.pump();
    // The sign-up code was sent moments ago: the server's 30 s resend cooldown applies.
    await tapButton(tester, 'Send WhatsApp code');
    await waitFor(tester, () => find.textContaining('Resend code in').evaluate().isNotEmpty, 'the cooldown');
    expect(loc(), AppRoute.phone.path);
    await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 31)));
    await tapButton(tester, 'Send WhatsApp code');
    await waitFor(tester, () => loc() == AppRoute.otp.path, 'the code screen');
    await keypad(tester, devCode);
    await waitFor(tester, () => loc() == AppRoute.twofa.path, 'the 2FA step');
    expect(c.read(sessionProvider).signedIn, isFalse, reason: 'not signed in before 2FA');

    await keypad(tester, Totp.code(setup.secret, DateTime.now().add(const Duration(seconds: 30))));
    await waitFor(tester, () => c.read(sessionProvider).signedIn, 'login');
    expect(c.read(sessionProvider).twofaEnabled, isTrue);
    expect(c.read(sessionProvider).onboarded, isTrue, reason: 'the server remembers onboarding');
    await waitFor(tester, () => loc() == AppRoute.home.path, 'Home, not KYC again');
  });

  testWidgets('logging in with a number that has no account says so', (tester) async {
    final c = await pumpApp(tester, env: Env.local);
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

    await tapButton(tester, 'Log in');
    await tester.enterText(find.byType(TextField), '090${List.generate(8, (_) => Random().nextInt(10)).join()}');
    await tester.pump();
    await tapButton(tester, 'Send WhatsApp code');
    await waitFor(tester, () => loc() == AppRoute.otp.path, 'the code screen');
    await keypad(tester, devCode);
    await waitFor(
      tester,
      () => find.text('No Jarina account uses this number. Sign up instead.').evaluate().isNotEmpty,
      'the no-account message',
    );
  });

  testWidgets("Markets show the server's live Quidax prices", (tester) async {
    final c = await pumpApp(tester, env: Env.local);
    final phone = '+23490${List.generate(8, (_) => Random().nextInt(10)).join()}';

    // Sign in through the real API, then skip KYC (covered above).
    final auth = c.read(authRepositoryProvider);
    final sent = (await tester.runAsync(() => auth.sendOtp(phoneE164: phone, channel: OtpChannel.whatsapp)))!;
    final outcome = (await tester.runAsync(() => auth.verifyOtp(challengeId: sent.valueOrNull!.id, code: devCode)))!;
    final session = (outcome.valueOrNull! as SignedIn).session;
    await c.read(sessionProvider.notifier).signIn(session);
    c.read(sessionProvider.notifier).update(const SessionState(signedIn: true, onboarded: true, twofaEnabled: true));
    await tester.pumpAndSettle();

    // What the server says BTC opened at (Quidax, 24 h ago).
    final quotes = (await tester.runAsync(() => c.read(apiClientProvider).get('quotes')))!;
    final btc = ((quotes.valueOrNull! as Map)['quotes'] as Map)['BTC'] as Map;
    final open = (btc['open'] as String).split('.').first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

    c.read(routerProvider).go('/asset/BTC');
    await waitFor(tester, () => find.textContaining(open).evaluate().isNotEmpty, 'BTC opening price $open');
    expect(find.textContaining('98,000,000'), findsNothing, reason: 'not the prototype price');
  });
}
