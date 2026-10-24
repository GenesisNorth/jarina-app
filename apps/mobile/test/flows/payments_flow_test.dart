import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_core/jarina_core.dart';
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

Future<void> slide(WidgetTester tester) async {
  final box = tester.getRect(find.byType(JSlideToConfirm));
  await tester.dragFrom(box.centerLeft + const Offset(28, 0), Offset(box.width, 0));
  await tester.pumpAndSettle();
}

Decimal _ngn(ProviderContainer c) => c.read(balancesProvider).value!.fiatOf(Currency.ngn).amount;

void main() {
  testWidgets('transfer to a bank beneficiary: keypad → confirm → PIN → sent', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(recipientsProvider, (_, _) {})
      ..read(routerProvider).go('/home/transfer');
    await tester.pumpAndSettle();
    final before = _ngn(c);

    await keypad(tester, '5');
    await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text('000')));
    await tester.pumpAndSettle();
    expect(find.text('₦5,000'), findsWidgets);

    // Bring the row above the floating tab bar before tapping it.
    await tester.scrollUntilVisible(
      find.text('Your @username, QR and account details'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ibrahim Musa'));
    await tester.pumpAndSettle();
    expect(find.textContaining('fee ₦25'), findsOneWidget);

    await slide(tester);
    await keypad(tester, '482957');
    await tester.pumpAndSettle();
    expect(find.text('₦5,000 sent to Ibrahim'), findsOneWidget);
    expect(_ngn(c), before - Decimal.fromInt(5025));
    expect(c.read(transferDraftProvider).amount, Decimal.zero, reason: 'draft cleared after sending');
  });

  testWidgets('cross-border shows what they receive and needs PIN + 2FA', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(recipientsProvider, (_, _) {});
    c.read(transferDraftProvider.notifier).setAmount(Decimal.fromInt(10000));
    c.read(routerProvider).go('/people');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Halima'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Halima gets'), findsOneWidget);
    expect(find.textContaining('fee ₦300'), findsOneWidget);

    await slide(tester);
    await keypad(tester, '482957');
    expect(find.text('Two-factor authentication'), findsOneWidget);
    await keypad(tester, FakeBackend.demoCode);
    await tester.pumpAndSettle();
    expect(find.text('₦10,000 sent to Halima'), findsOneWidget);
    expect(c.read(lastPaymentProvider)!.$2.status.name, 'pending', reason: 'payout settles in minutes');
  });

  testWidgets('P2P: unknown user blocks, known user gets cash with PIN', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(recipientsProvider, (_, _) {})
      ..read(routerProvider).go('/p2p');
    await tester.pumpAndSettle();
    final before = _ngn(c);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'nobody_here');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Choose a Jarina user'), findsOneWidget);

    await tester.enterText(fields.at(0), 'zainab');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Zainab Yusuf · @zainab'), findsOneWidget);

    await tester.enterText(fields.at(1), '2000');
    await tester.pumpAndSettle();
    await slide(tester);
    await keypad(tester, '482957');
    await tester.pumpAndSettle();
    expect(find.text('Delivered instantly. Free.'), findsOneWidget);
    expect(_ngn(c), before - Decimal.fromInt(2000));
  });

  testWidgets('electricity: meter lookup, PIN, token shown', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(activityProvider, (_, _) {})
      ..read(routerProvider).go('/bill/electricity');
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '01234567890');
    await tester.pumpAndSettle();
    expect(find.text('Customer: AMINU BELLO · Prepaid'), findsOneWidget);

    await tester.enterText(fields.at(1), '500');
    await tester.pumpAndSettle();
    expect(find.textContaining('Between ₦1,000'), findsOneWidget);

    await tester.tap(find.text('₦5,000'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(JButton, 'Pay ₦5,000'));
    await tester.pumpAndSettle();
    await keypad(tester, '482957');
    await tester.pumpAndSettle();
    expect(find.text('Bill paid'), findsOneWidget);
    expect(find.text('Electricity token'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d{4}-\d{4}-\d{4}-\d{4}-\d{4}$')), findsOneWidget);
  });

  testWidgets('payment screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: _full, clock: () => _now);
    c.listen(recipientsProvider, (_, _) {});
    final router = c.read(routerProvider);
    final halima = (await c.read(recipientsProvider.future)).firstWhere((r) => r.kind == RecipientKind.crossBorder);
    c.read(selectedRecipientProvider.notifier).set(halima);
    c.read(transferDraftProvider.notifier).setAmount(Decimal.fromInt(250000));
    for (final path in [
      '/home/transfer', '/people', '/payconfirm', '/p2p', '/p2p?mode=request&amount=5000', //
      '/bill/airtime', '/bill/data', '/bill/cable', '/bill/electricity', '/withdraw',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path overflowed');
    }
  });
}
