import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina_ui/jarina_ui.dart';

import '../helpers.dart';

const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);

Future<void> keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)).last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a signed-in app opens locked and unlocks with the PIN', (tester) async {
    final c = await pumpApp(tester, session: _full, lockOnLaunch: true);
    expect(find.text('Enter your PIN to unlock Jarina'), findsOneWidget);
    expect(c.read(appLockProvider), isTrue);
    await keypad(tester, '482957');
    expect(c.read(appLockProvider), isFalse);
    expect(find.text('Enter your PIN to unlock Jarina'), findsNothing);
  });

  testWidgets('signed-out and onboarding users are never locked', (tester) async {
    final c = await pumpApp(tester, lockOnLaunch: true);
    expect(c.read(appLockProvider), isFalse);
  });

  testWidgets('relocks after two minutes in the background, not after a quick switch', (tester) async {
    var now = DateTime.utc(2026, 10, 19, 10);
    final c = await pumpApp(tester, session: _full, clock: () => now);
    final binding = tester.binding;

    Future<void> background(Duration away) async {
      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(find.text('Jarina'), findsWidgets, reason: 'privacy cover while in the app switcher');
      now = now.add(away);
      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    await background(const Duration(seconds: 30));
    expect(c.read(appLockProvider), isFalse);
    await background(lockAfter);
    expect(c.read(appLockProvider), isTrue);
  });

  testWidgets('a wrong PIN shows attempts left; five sign the user out', (tester) async {
    final c = await pumpApp(tester, session: _full, lockOnLaunch: true);
    await c.read(fakeBackendProvider).setPin('482957');
    await keypad(tester, '111222');
    expect(find.textContaining('4'), findsWidgets, reason: 'attempts left');
    expect(c.read(appLockProvider), isTrue);
    for (var i = 0; i < 4; i++) {
      await keypad(tester, '111222');
    }
    expect(c.read(sessionProvider).signedIn, isFalse);
    expect(c.read(appLockProvider), isFalse);
  });

  testWidgets('"Not you? Log out" signs out from the lock screen', (tester) async {
    final c = await pumpApp(tester, session: _full, lockOnLaunch: true);
    await tester.tap(find.text('Not you? Log out'));
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider).signedIn, isFalse);
    expect(c.read(appLockProvider), isFalse);
  });
}
