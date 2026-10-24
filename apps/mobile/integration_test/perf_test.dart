import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Frame timings while scrolling the heaviest screens, with live prices
/// ticking. Run in profile mode on a real low-end Android phone (the
/// simulator can't run profile builds, and debug timings are meaningless):
///
/// ```sh
/// flutter drive --profile --driver test_driver/perf_driver.dart \
///   --target integration_test/perf_test.dart -d ANDROID_DEVICE_ID
/// ```
///
/// Budget: 90th-percentile build and raster under 16 ms, under 5% missed frames.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling stays smooth', (tester) async {
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
      ],
    );
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JarinaApp()));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final router = container.read(routerProvider);

    for (final path in ['/home', '/stocks', '/crypto', '/more/activity']) {
      router.go(path);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await binding.watchPerformance(() async {
        final list = find.byType(Scrollable).first;
        for (var i = 0; i < 3; i++) {
          await tester.fling(list, const Offset(0, -600), 2500);
          await tester.pumpAndSettle();
          await tester.fling(list, const Offset(0, 600), 2500);
          await tester.pumpAndSettle();
        }
      }, reportKey: 'scroll${path.replaceAll('/', '_')}');
    }
  });
}
