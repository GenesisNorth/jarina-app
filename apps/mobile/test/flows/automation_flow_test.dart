import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/automation/application/automation_state.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_ui/jarina_ui.dart';

import '../helpers.dart';

const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);
final _now = DateTime.utc(2026, 10, 19, 10);

Future<void> keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)).last);
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

/// Scrolls the top-most (last built) list until [f] is on screen.
Future<void> scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 300, scrollable: find.byType(Scrollable).hitTestable().first);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

Future<void> slide(WidgetTester tester) async {
  final box = tester.getRect(find.byType(JSlideToConfirm));
  await tester.dragFrom(box.centerLeft + const Offset(28, 0), Offset(box.width, 0));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('create an auto-buy rule with the PIN, then pause and delete it', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(autopilotRulesProvider, (_, _) {})
      ..listen(quotesProvider, (_, _) {})
      ..read(routerProvider).go('/rule?asset=DANGCEM');
    await tester.pumpAndSettle();
    await scrollTo(tester, find.textContaining('When DANGCEM trades between'));
    expect(find.textContaining('When DANGCEM trades between'), findsOneWidget, reason: 'summary');

    await slide(tester);
    expect(find.textContaining('Authorise Autopilot to trade for you'), findsOneWidget);
    await keypad(tester, '482957');
    expect(find.text('Stock Autopilot'), findsWidgets);
    final rules = c.read(autopilotRulesProvider).value!;
    expect(rules.first.assetId, 'DANGCEM');
    expect(rules.first.condition, RuleCondition.range);
    expect(rules.length, 5, reason: '4 seeded + 1');

    final firstSwitch = find.byType(Switch).first;
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();
    expect(c.read(autopilotRulesProvider).value!.first.enabled, isFalse);

    await tester.tap(find.byTooltip('Delete rule').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(c.read(autopilotRulesProvider).value!.length, 4);
  });

  testWidgets('switching to auto-sell offers take-profit and stop-loss', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(quotesProvider, (_, _) {})
      ..read(routerProvider).go('/rule?asset=MTNN');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto-sell'));
    await tester.pumpAndSettle();
    expect(find.text('Rises above'), findsWidgets);
    expect(find.text('Falls below (stop-loss)'), findsOneWidget);
    await scrollTo(tester, find.textContaining('When MTNN rises above'));
    expect(find.textContaining('When MTNN rises above'), findsOneWidget);
    expect(find.text('Slide to save auto-sell rule'), findsOneWidget);
  });

  testWidgets('set a price alert and see it in the list', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(priceAlertsProvider, (_, _) {})
      ..listen(quotesProvider, (_, _) {});
    final router = c.read(routerProvider)..go('/alerts');
    await tester.pumpAndSettle();
    expect(find.text('MTNN above ₦900.00'), findsOneWidget);
    // Not awaited: push completes only when the alert screen pops.
    unawaited(router.push('/alert?asset=MTNN'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('−10%'));
    await tester.tap(find.text('−10%'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.textContaining('goes below'));
    expect(find.textContaining('goes below'), findsOneWidget);
    await tester.tap(find.widgetWithText(JButton, 'Set alert'));
    await tester.pumpAndSettle();
    expect(c.read(priceAlertsProvider).value!.first.direction, AlertDirection.below);
    expect(find.text('Price alerts'), findsOneWidget, reason: 'back on the list');
  });

  testWidgets('change the transaction PIN: current, new, confirm', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c.read(routerProvider).go('/account');
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Change transaction PIN'));
    await tester.tap(find.text('Change transaction PIN'));
    await tester.pumpAndSettle();
    await keypad(tester, '482957');
    expect(find.text('Create a new PIN'), findsOneWidget);
    await keypad(tester, '123456');
    expect(find.text('Create a new PIN'), findsOneWidget, reason: 'weak PIN rejected');
    await keypad(tester, '958372');
    expect(find.text('Confirm your new PIN'), findsOneWidget);
    await keypad(tester, '958373');
    expect(find.text('Create a new PIN'), findsOneWidget, reason: 'mismatch goes back');
    await keypad(tester, '958372');
    await keypad(tester, '958372');
    expect(find.text('PIN changed'), findsOneWidget);
  });

  testWidgets('support chat answers a quick topic and switches language', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c.read(routerProvider).go('/chat');
    await tester.pumpAndSettle();
    expect(find.textContaining("I'm Aisha from Jarina Support"), findsOneWidget);
    await tester.tap(find.text('Withdrawal delay'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Crypto withdrawals usually arrive within minutes'), findsOneWidget);
    await tester.tap(find.text('HA'));
    await tester.pumpAndSettle();
    expect(find.text('Hira cikin Hausa'), findsWidgets);
  });

  testWidgets('More: dark mode, language and log out', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    final router = c.read(routerProvider)..go('/more');
    await tester.pumpAndSettle();
    expect(find.text('Aminu Bello'), findsOneWidget);

    router.go('/language');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Harshen Hausa'));
    await tester.pumpAndSettle();
    router.go('/more');
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Harshen Hausa'));
    expect(find.text('Harshen Hausa'), findsOneWidget, reason: 'language row shows the new language');
    router.go('/language');
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();

    router.go('/more');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Log out'), 300, scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider).signedIn, isFalse);
  });

  testWidgets('Phase 8 screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: _full, clock: () => _now);
    c
      ..listen(quotesProvider, (_, _) {})
      ..listen(autopilotRulesProvider, (_, _) {});
    final router = c.read(routerProvider);
    for (final path in [
      '/more', '/account', '/language', '/chat', '/autopilot?type=stock', '/autopilot?type=crypto', //
      '/rule?asset=DANGCEM', '/rule?asset=BTC', '/alerts', '/alert?asset=MTNN', '/picker?for=rule&kind=stocks',
      '/asset/DANGCEM',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path overflowed');
    }
  });
}
