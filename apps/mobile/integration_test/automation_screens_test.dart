import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures Autopilot, alerts, More, account, language and chat on a device.
///
/// ```sh
/// flutter drive --driver test_driver/integration_test.dart \
///   --target integration_test/automation_screens_test.dart -d DEVICE_ID
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 8 screens', (tester) async {
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
      await binding.takeScreenshot('a${(++n).toString().padLeft(2, '0')}-$name');
    }

    Future<void> go(String path, String name) async {
      router.go(path);
      await tester.pumpAndSettle();
      await shot(name);
    }

    await go('/more', 'more');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot('more-tools');
    await go('/autopilot?type=stock', 'autopilot-stock');
    await go('/autopilot?type=crypto', 'autopilot-crypto');
    await go('/rule?asset=DANGCEM', 'rule-buy');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
    await shot('rule-buy-amount');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await shot('rule-summary');
    await go('/alerts', 'alerts');
    await go('/alert?asset=MTNN', 'alert');
    await go('/asset/DANGCEM', 'asset-with-rules');
    await go('/account', 'account');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await shot('account-security');
    await go('/language', 'language');
    await go('/chat', 'chat');
    await tester.tap(find.text('Withdrawal delay'));
    await tester.pumpAndSettle();
    await shot('chat-reply');
    await container.read(themeModeSettingProvider.notifier).set(ThemeMode.dark);
    await go('/more', 'more-dark');
    await go('/autopilot?type=stock', 'autopilot-dark');
    await container.read(themeModeSettingProvider.notifier).set(ThemeMode.light);
  });
}
