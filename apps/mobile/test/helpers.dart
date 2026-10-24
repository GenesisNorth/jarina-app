import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real app with in-memory storage and an instant fake backend.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  SessionState session = const SessionState(),
  Map<String, Object> prefs = const {},
  Size size = const Size(390, 844),
}) async {
  // Phone-sized surface (iPhone 14/15) unless a test asks for another.
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // Stops looping decorative animations so pumpAndSettle can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  // The asset cache is global; a load left pending by a previous test would
  // never complete in this test's fake-async zone.
  rootBundle.clear();
  SharedPreferences.setMockInitialValues({'installed': true, ...prefs});
  FlutterSecureStorage.setMockInitialValues({});
  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(Env.dev),
      sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
      sessionStoreProvider.overrideWithValue(SessionStore()),
      initialSessionProvider.overrideWithValue(session),
      fakeBackendProvider.overrideWithValue(FakeBackend(latency: Duration.zero)),
      fakeLedgerProvider.overrideWith((ref) {
        final ledger = FakeLedger(latency: Duration.zero, tick: Duration.zero);
        ref.onDispose(ledger.dispose);
        return ledger;
      }),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const JarinaApp()));
  await tester.pumpAndSettle();
  return container;
}
