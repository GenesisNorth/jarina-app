import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the crypto screens on a device.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/crypto_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('crypto screens', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    SharedPreferences.setMockInitialValues({'installed': true});
    FlutterSecureStorage.setMockInitialValues({});
    // Monday 11:00 WAT so the market is open.
    final open = DateTime.utc(2026, 10, 19, 10);
    final container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(Env.staging),
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        initialSessionProvider.overrideWithValue(
          const SessionState(signedIn: true, onboarded: true, twofaEnabled: true),
        ),
        clockProvider.overrideWithValue(() => open),
        fakeLedgerProvider.overrideWith(
          (ref) => FakeLedger(latency: Duration.zero, tick: Duration.zero, clock: () => open),
        ),
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JarinaApp()));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);

    var n = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot('c${(++n).toString().padLeft(2, '0')}-$name');
    }

    Future<void> go(String path, String name) async {
      router.go(path);
      await tester.pumpAndSettle();
      await shot(name);
    }

    await go('/crypto', 'crypto');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot('crypto-services');
    await go('/qcoin/USDT', 'coin-usdt');
    await go('/qcoin/XRP', 'coin-xrp-memo');
    await go('/qwallets', 'wallets');
    router.go('/qswap?from=USDT&to=BTC');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '100');
    await tester.pump(const Duration(milliseconds: 500));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('swap');
    router.go('/qwd?coin=USDT');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '0x52908400098527886E0F7030069857D2E4169EE7');
    await tester.enterText(find.byType(TextField).at(1), '50');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('withdraw-wrong-network');
    await go('/qpro', 'pro');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot('pro-order');
    await go('/qorders', 'orders');
    await go('/qhist', 'history');
    await go('/qbuy', 'buy');
    await go('/qcashout', 'cashout');
    await go('/qloan', 'loan');
    await go('/qnotif', 'notifications');
    expect(container.read(tradingRepositoryProvider), isNotNull);
  });
}
