import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina_ui/jarina_ui.dart';

import '../helpers.dart';

/// Taps keys on the on-screen keypad.
Future<void> keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
    await tester.pump();
  }
  // Screens pause briefly after the last digit (PIN dots fill) before acting.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final f = find.widgetWithText(JButton, label);
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a new user signs up end to end and lands on Home', (tester) async {
    final c = await pumpApp(tester);
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

    // Welcome → Country
    await tapButton(tester, 'Create account');
    expect(loc(), AppRoute.country.path);

    // Step 1 · Nigeria
    await tester.tap(find.bySemanticsLabel('Nigeria'));
    await tester.pumpAndSettle();
    expect(loc(), AppRoute.langpick.path);

    // Step 2 · English (default) → Continue
    await tapButton(tester, 'Continue');
    expect(loc(), AppRoute.phone.path);

    // Step 3 · WhatsApp number: too short first, then valid
    await tester.enterText(find.byType(TextField), '0801234');
    await tester.pump();
    await tapButton(tester, 'Send WhatsApp code');
    expect(find.text('Number is too short'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '08012345678');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '0801 234 5678',
      reason: 'formatted as typed',
    );
    await tapButton(tester, 'Send WhatsApp code');
    expect(loc(), AppRoute.otp.path);

    // Step 4 · Wrong code shows an error and clears, right code signs in
    await keypad(tester, '000000');
    expect(find.text("That code isn't right. Try again."), findsOneWidget);
    await keypad(tester, FakeBackend.demoCode);
    expect(c.read(sessionProvider).signedIn, isTrue);
    expect(loc(), AppRoute.kyc1.path);

    // Step 5 · Details: validation, then valid
    await tapButton(tester, 'Continue');
    expect(find.text('This field is required'), findsWidgets);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Aminu');
    await tester.pump();
    await tester.enterText(fields.at(2), 'Bello');
    await tester.pump();
    await tester.enterText(fields.at(3), '12051990');
    await tester.pump();
    await tester.enterText(fields.at(4), 'aminu@example.com');
    await tester.pump();
    expect(find.text('12 / 05 / 1990'), findsOneWidget);
    await tapButton(tester, 'Continue');
    expect(loc(), AppRoute.username.path);

    // Step 6 · Username: taken handle, then a free suggestion
    await tester.enterText(find.byType(TextField), 'aminu');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('@aminu is taken. Try a suggestion.'), findsOneWidget);
    await tester.tap(find.text('@bello.aminu'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('@bello.aminu is available'), findsOneWidget);
    await tapButton(tester, 'Claim @bello.aminu');
    expect(loc(), AppRoute.kyc2.path);

    // Step 7 · BVN: registry miss, then valid
    await tester.enterText(find.byType(TextField), '00000000000');
    await tester.pump();
    await tapButton(tester, 'Continue');
    expect(find.text("We couldn't verify this number. Check it and try again."), findsOneWidget);
    await tester.enterText(find.byType(TextField), '22212345678');
    await tester.pump();
    await tapButton(tester, 'Continue');
    expect(loc(), AppRoute.kyc3.path);

    // Step 8 · Liveness
    await tapButton(tester, 'Start camera');
    await tapButton(tester, 'Continue');
    expect(loc(), AppRoute.kyc4.path);

    // Step 9 · Address
    await tester.tap(find.text('Select state'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)), 'kan');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Kano')));
    await tester.pumpAndSettle();
    final addr = find.byType(TextField);
    await tester.enterText(addr.at(0), 'Kano');
    await tester.pump();
    await tester.enterText(addr.at(1), 'No. 12 Zoo Road');
    await tester.pump();
    await tester.ensureVisible(find.text('Trader'));
    await tester.tap(find.text('Trader'));
    await tapButton(tester, 'Continue');
    expect(loc(), AppRoute.kyc5.path);

    // Steps 10–11 · PIN: weak rejected, mismatch restarts, then match
    await keypad(tester, '123456');
    expect(find.text('Too easy to guess. Avoid birthdays and repeated digits.'), findsOneWidget);
    await keypad(tester, '739462');
    expect(find.text('Confirm your PIN'), findsOneWidget);
    await keypad(tester, '739463');
    expect(find.text("PINs don't match. Create it again."), findsOneWidget);
    await keypad(tester, '739462');
    await keypad(tester, '739462');
    expect(loc(), AppRoute.kyc6.path);

    // Step 12 · 2FA with a wrong then the demo code
    await tester.enterText(find.byType(TextField), '111111');
    await tester.pump();
    await tapButton(tester, 'Verify & turn on 2FA');
    expect(find.text("That code isn't right. Try again."), findsOneWidget);
    await tester.enterText(find.byType(TextField), FakeBackend.demoCode);
    await tester.pump();
    await tapButton(tester, 'Verify & turn on 2FA');
    expect(loc(), AppRoute.kycdone.path);
    expect(c.read(sessionProvider).twofaEnabled, isTrue);

    // Verified → Home
    await tapButton(tester, 'Go to Jarina');
    expect(loc(), AppRoute.home.path);
    expect(c.read(sessionProvider).onboarded, isTrue);
  });

  testWidgets('skipping 2FA leaves the account limited', (tester) async {
    final c = await pumpApp(tester, session: const SessionState(signedIn: true, kycStep: 'kyc6'));
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
    expect(loc(), AppRoute.kyc6.path, reason: 'resumes at the saved KYC step');

    await tapButton(tester, 'Skip for now');
    expect(loc(), AppRoute.kycdone.path);
    await tapButton(tester, 'Go to Jarina');

    c.read(routerProvider).go(AppRoute.qswap.path);
    await tester.pumpAndSettle();
    expect(loc(), AppRoute.disabled.path);
    await tapButton(tester, 'Turn on 2FA');
    expect(loc(), AppRoute.kyc6.path);
    expect(find.text('Skip for now'), findsNothing, reason: 'no skipping once onboarded');
  });

  testWidgets('login is WhatsApp code then 2FA, with no password', (tester) async {
    final c = await pumpApp(tester);
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;

    await tapButton(tester, 'Log in');
    expect(find.text('Log in to Jarina'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget, reason: 'phone only, no password');
    await tester.enterText(find.byType(TextField), '08012345678');
    await tester.pump();
    await tapButton(tester, 'Send WhatsApp code');
    expect(loc(), AppRoute.otp.path);
    expect(find.text('WELCOME BACK · VERIFY'), findsOneWidget);
    expect(find.text('Country'), findsNothing, reason: 'no sign-up tracker on login');

    await keypad(tester, FakeBackend.demoCode);
    expect(loc(), AppRoute.twofa.path);
    expect(c.read(sessionProvider).signedIn, isFalse, reason: 'not signed in before 2FA');

    await keypad(tester, '000000');
    expect(find.text("That code isn't right. Try again."), findsOneWidget);
    await keypad(tester, FakeBackend.demoCode);
    expect(loc(), AppRoute.home.path);
    expect(c.read(sessionProvider).twofaEnabled, isTrue);
  });

  testWidgets('fits a small phone with large text without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: const SessionState(signedIn: true));
    for (final r in [
      AppRoute.kyc1,
      AppRoute.username,
      AppRoute.kyc2,
      AppRoute.kyc3,
      AppRoute.kyc4,
      AppRoute.kyc5,
      AppRoute.kyc6,
    ]) {
      c.read(routerProvider).go(r.path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '${r.name} overflowed');
    }
  });
}
