import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
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

void main() {
  testWidgets('swap USDT → BTC with a live quote and PIN', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..read(routerProvider).go('/qswap?from=USDT&to=BTC');
    await tester.pumpAndSettle();
    expect(find.text('Enter an amount'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '100');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Slide to swap'), findsOneWidget, reason: 'quote arrived');

    await slide(tester);
    await keypad(tester, '482957');
    expect(find.text('Swapped USDT → BTC'), findsOneWidget, reason: 'receipt');
    expect(c.read(balancesProvider).value!.qtyOf('USDT'), Decimal.fromInt(220));
  });

  testWidgets('withdraw USDT rejects a wrong-network address, then sends with PIN + 2FA', (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    c
      ..listen(balancesProvider, (_, _) {})
      ..listen(cryptoTransfersProvider, (_, _) {})
      ..read(routerProvider).go('/qwd?coin=USDT');
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '0x52908400098527886E0F7030069857D2E4169EE7');
    await tester.pump();
    expect(find.text("This isn't a valid TRON · TRC-20 address"), findsOneWidget);

    await tester.enterText(fields.at(0), 'TNkT913fa7KfZ7n462FvjiNm3H5FcXmUzf');
    await tester.enterText(fields.at(1), '50');
    await tester.pump();
    expect(find.text('49 USDT'), findsOneWidget, reason: 'recipient gets amount minus 1 USDT fee');

    await tester.tap(find.widgetWithText(JButton, 'Withdraw'));
    await tester.pumpAndSettle();
    await keypad(tester, '482957');
    expect(find.text('Two-factor authentication'), findsOneWidget);
    await keypad(tester, FakeBackend.demoCode);

    expect(c.read(balancesProvider).value!.qtyOf('USDT'), Decimal.fromInt(270));
    expect(c.read(cryptoTransfersProvider).value!.first.status, TransferStatus.processing);
  });

  testWidgets("switching coins never shows the previous coin's deposit address", (tester) async {
    final c = await pumpApp(tester, session: _full, clock: () => _now);
    final router = c.read(routerProvider)..go('/qcoin/USDT');
    await tester.pumpAndSettle();
    expect(find.textContaining('Send only USDT on TRON · TRC-20'), findsOneWidget);
    final usdtAddress = tester.widget<Text>(find.byKey(const ValueKey('deposit-address'))).data!;
    expect(usdtAddress, startsWith('T'));

    router.go('/qcoin/XRP');
    await tester.pumpAndSettle();
    expect(find.textContaining('Send only XRP on XRP Ledger · XRP'), findsOneWidget);
    expect(find.textContaining('TRON'), findsNothing);
    final xrpAddress = tester.widget<Text>(find.byKey(const ValueKey('deposit-address'))).data!;
    expect(xrpAddress, startsWith('r'));
    expect(AddressRules.isValid('XRP', xrpAddress), isTrue);
    expect(find.textContaining('Memo / tag'), findsOneWidget, reason: 'XRP needs a destination tag');
  });

  testWidgets('crypto screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(320, 568), session: _full, clock: () => _now);
    final router = c.read(routerProvider);
    for (final path in [
      '/crypto', '/qcoin/USDT', '/qcoin/XRP', '/usdt', '/qwallets', '/qswap', '/qwd?coin=USDT', '/qhist', //
      '/qorders', '/qpro', '/qbuy', '/qcashout', '/qauto', '/qloan', '/qnotif',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$path overflowed');
    }
  });
}
