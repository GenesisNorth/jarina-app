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
import 'package:jarina_ui/jarina_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the Stocks tab, stock detail and the buy flow on a device.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/stocks_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('stocks screens', (tester) async {
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
      await binding.takeScreenshot('s${(++n).toString().padLeft(2, '0')}-$name');
    }

    router.go('/stocks');
    await shot('stocks');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await shot('stocks-list');

    router.go('/asset/MTNN');
    await shot('asset');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await shot('asset-scrolled');

    router.go('/entry?asset=MTNN&side=buy');
    await tester.pumpAndSettle();
    await shot('buy-empty');
    await tester.enterText(find.byType(TextField), '50000');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('buy-filled');

    final box = tester.getRect(find.byType(JSlideToConfirm));
    await tester.dragFrom(box.centerLeft + const Offset(28, 0), Offset(box.width, 0));
    await shot('review');

    await tester.tap(find.widgetWithText(JButton, 'Confirm'));
    await tester.pumpAndSettle();
    for (final d in '482957'.split('')) {
      await tester.tap(find.descendant(of: find.byType(JKeypad), matching: find.text(d)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await shot('order-placed');

    router.go('/entry?asset=MTNN&side=sell');
    await tester.pumpAndSettle();
    await tester.tap(find.text('50%'));
    await shot('sell-half');

    router.go('/picker?kind=stocks');
    await shot('picker');
    expect(container.read(tradingRepositoryProvider), isNotNull);
  });
}
