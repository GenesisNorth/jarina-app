import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

import '../helpers.dart';

const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);

Future<void> keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the dashboard, and the eye hides balances', (tester) async {
    await pumpApp(tester, session: _full);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.textContaining('₦'), findsWidgets);

    await tester.tap(find.byTooltip('Hide balances'));
    await tester.pumpAndSettle();
    expect(find.text('••••••'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Bought GTCO'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('Bought GTCO'), findsOneWidget, reason: 'recent activity');
  });

  testWidgets('convert NGN → GHS with PIN, then see the receipt and new balance', (tester) async {
    final c = await pumpApp(tester, session: _full);
    c.read(routerProvider).go('${AppRoute.convert.path}?from=NGN');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '200000');
    await tester.pump();
    expect(find.text('Exceeds your balance'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '13500');
    await tester.pump();
    expect(find.text('99.50'), findsOneWidget, reason: '100 GHS minus 0.5% fee');

    await tester.tap(find.widgetWithText(JButton, 'Convert'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your transaction PIN'), findsOneWidget);
    await keypad(tester, '482957'); // no PIN set in this session: test builds accept any 6 digits

    expect(c.read(routerProvider).routerDelegate.currentConfiguration.uri.path, startsWith('/receipt/'));
    expect(find.text('Converted NGN to GHS'), findsOneWidget);
    final b = c.read(balancesProvider).value!;
    expect(b.fiatOf(Currency.ngn), Money.parse('170700', Currency.ngn));
    expect(b.fiatOf(Currency.ghs), Money.parse('1349.50', Currency.ghs));
  });

  testWidgets('pay a request from Receive', (tester) async {
    final c = await pumpApp(tester, session: _full);
    // Keep balances live: Riverpod pauses providers nobody is watching.
    c.listen(balancesProvider, (_, _) {});
    c.read(routerProvider).go(AppRoute.receive.path);
    await tester.pumpAndSettle();
    expect(find.text('Zainab Yusuf requested ₦3,000'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(JButton, 'Pay').first);
    await tester.tap(find.widgetWithText(JButton, 'Pay').first);
    await tester.pumpAndSettle();
    await keypad(tester, '482957');
    expect(find.text('Paid Zainab Yusuf'), findsOneWidget, reason: 'receipt title');
    expect(c.read(balancesProvider).value!.fiatOf(Currency.ngn), Money.parse('181200', Currency.ngn));
  });

  testWidgets('activity filters and opens a cross-border receipt', (tester) async {
    final c = await pumpApp(tester, session: _full);
    c.read(routerProvider).go(AppRoute.activity.path);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(JChip, 'Stocks'));
    await tester.pumpAndSettle();
    expect(find.text('Bought GTCO'), findsOneWidget);
    expect(find.text('Sent to Halima Issoufou'), findsNothing);

    await tester.ensureVisible(find.widgetWithText(JChip, 'Transfers'));
    await tester.tap(find.widgetWithText(JChip, 'Transfers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sent to Halima Issoufou'));
    await tester.pumpAndSettle();
    expect(find.text('Cross-border transfer'), findsOneWidget);
    expect(find.text('Nigeria → Niger'), findsOneWidget);
  });

  testWidgets('money screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: _full);
    final router = c.read(routerProvider);
    for (final path in ['/home', '/wallets', '/more/activity', '/fiat/GHS', '/fiatadd/NGN', '/convert', '/receive']) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path overflowed');
    }
    final txId = (await c.read(activityProvider.future)).first.id;
    router.go('/receipt/$txId');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'receipt overflowed');
  });
}
