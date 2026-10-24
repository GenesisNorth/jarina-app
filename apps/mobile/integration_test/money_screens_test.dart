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
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the Home, Wallets, Activity and money screens on a device.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/money_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('money screens', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    SharedPreferences.setMockInitialValues({'installed': true});
    FlutterSecureStorage.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(Env.staging),
        lockOnLaunchProvider.overrideWithValue(false),
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        initialSessionProvider.overrideWithValue(
          const SessionState(signedIn: true, onboarded: true, twofaEnabled: true),
        ),
        // Frozen prices so screenshots are stable.
        fakeLedgerProvider.overrideWith((ref) => FakeLedger(latency: Duration.zero, tick: Duration.zero)),
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JarinaApp()));
    await tester.pumpAndSettle();
    final router = container.read(routerProvider);

    var n = 0;
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot('m${(++n).toString().padLeft(2, '0')}-$name');
    }

    Future<void> go(String path) async {
      router.go(path);
      await tester.pumpAndSettle();
    }

    await shot('home');
    await tester.tap(find.byTooltip('Menu').first);
    await shot('drawer');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot('home-scrolled');

    await go('/wallets');
    await shot('wallets');
    await go('/fiat/GHS');
    await shot('fiat-ghs');
    await go('/fiatadd/NGN');
    await shot('add-money');
    await go('/convert?from=NGN');
    await tester.enterText(find.byType(TextField), '13500');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('convert');
    await tester.tap(find.widgetWithText(JButton, 'Convert'));
    await shot('pin-sheet');
    for (final d in '482957'.split('')) {
      await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    await shot('receipt-convert');

    await go('/receive');
    await shot('receive');
    await go('/more/activity');
    await shot('activity');
    final cross = (await container.read(activityProvider.future)).firstWhere((t) => t.corridor != null);
    await go('/receipt/${cross.id}');
    await shot('receipt-crossborder');
    expect(container.read(walletRepositoryProvider), isNotNull);
  });
}
