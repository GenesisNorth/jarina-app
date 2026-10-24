import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

import '../helpers.dart';

const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);
final _mondayOpen = DateTime.utc(2026, 10, 19, 10);

Future<void> slide(WidgetTester tester) async {
  final box = tester.getRect(find.byType(JSlideToConfirm));
  await tester.dragFrom(box.centerLeft + const Offset(28, 0), Offset(box.width, 0));
  await tester.pumpAndSettle();
}

Future<void> keypad(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('buy MTNN from the stocks tab through review, PIN and receipt', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _mondayOpen);
    // Keep these live: Riverpod pauses providers no widget is watching.
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(activityProvider, (_, _) {});
    c.read(routerProvider).go('/stocks');
    await tester.pumpAndSettle();
    expect(find.text('Stock portfolio value'), findsOneWidget);

    // Holdings row → asset detail.
    await tester.tap(find.text('MTNN').first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Your position'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('400 shares'), findsOneWidget);

    await tester.tap(find.widgetWithText(JButton, 'Buy'));
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount'), findsOneWidget, reason: 'slide disabled until an amount');

    await tester.enterText(find.byType(TextField), '50000');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await slide(tester);

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Licensed partner broker'), findsOneWidget);
    await tester.tap(find.widgetWithText(JButton, 'Confirm'));
    await tester.pumpAndSettle();
    await keypad(tester, '482957');

    expect(find.text('Order placed'), findsOneWidget);
    final txs = c.read(activityProvider).value!;
    expect(txs.first.title, 'Bought MTNN');
    expect(txs.first.status, TxStatus.successful);
    expect(c.read(balancesProvider).value!.qtyOf('MTNN') > Decimal.fromInt(400), isTrue);

    await tester.tap(find.widgetWithText(JButton, 'View receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Stock trade'), findsOneWidget);
  });

  testWidgets('cannot buy more than the balance; sell is limited to holdings', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _mondayOpen);
    c.read(routerProvider).go('/entry?asset=MTNN&side=buy');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '900000');
    await tester.pump();
    expect(find.text('Not enough balance'), findsOneWidget);
    expect(find.text('Enter an amount'), findsOneWidget, reason: 'slide disabled');

    await tester.tap(find.text('Sell').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '401');
    await tester.pump();
    expect(find.text("You don't hold that many shares"), findsOneWidget);

    await tester.tap(find.text('Max'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '400');
  });

  testWidgets('stocks screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: _full, clock: () => _mondayOpen);
    final router = c.read(routerProvider);
    for (final path in [
      '/stocks',
      '/asset/MTNN',
      '/entry?asset=MTNN&side=buy',
      '/entry?asset=MTNN&side=sell',
      '/picker?kind=stocks',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path overflowed');
    }
  });
}
