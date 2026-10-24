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
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the transfer, P2P and bill screens on a device.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/payments_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('payment screens', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    SharedPreferences.setMockInitialValues({'installed': true});
    FlutterSecureStorage.setMockInitialValues({});
    // Monday 11:00 WAT so the market is open.
    final open = DateTime.utc(2026, 10, 19, 10);
    final container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(Env.staging),
        lockOnLaunchProvider.overrideWithValue(false),
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
      await binding.takeScreenshot('p${(++n).toString().padLeft(2, '0')}-$name');
    }

    Future<void> go(String path, String name) async {
      router.go(path);
      await tester.pumpAndSettle();
      await shot(name);
    }

    await go('/home/transfer', 'transfer');
    container.read(transferDraftProvider.notifier).setAmount(Decimal.fromInt(25000));
    await shot('transfer-amount');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await shot('transfer-types');
    await go('/people', 'people');
    await tester.tap(find.text('Halima'));
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('payconfirm-crossborder');
    await go('/p2p', 'p2p');
    await tester.enterText(find.byType(TextField).first, 'zainab');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.enterText(find.byType(TextField).at(1), '2000');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('p2p-filled');
    await go('/p2p?mode=request&amount=5000', 'p2p-request');
    for (final k in ['airtime', 'data', 'cable', 'electricity']) {
      await go('/bill/$k', 'bill-$k');
    }
    await tester.enterText(find.byType(TextField).first, '01234567890');
    await tester.pump(const Duration(milliseconds: 300));
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('bill-electricity-verified');
  });
}
