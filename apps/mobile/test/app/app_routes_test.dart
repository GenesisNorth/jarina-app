import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/onboarding/presentation/welcome_screen.dart';

import '../helpers.dart';

void main() {
  const full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);

  testWidgets('starts on welcome when signed out', (tester) async {
    await pumpApp(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('every route opens without errors for the session that may see it', (tester) async {
    final container = await pumpApp(tester, session: full);
    final router = container.read(routerProvider);

    for (final r in AppRoute.values) {
      final session = switch (r.group) {
        RouteGroup.preAuth => const SessionState(),
        RouteGroup.kyc => const SessionState(signedIn: true),
        _ => r == AppRoute.disabled ? const SessionState(signedIn: true, onboarded: true) : full,
      };
      container.read(sessionProvider.notifier).update(session);
      router.goNamed(r.name, pathParameters: r.sampleParams);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: r.name);

      // These need state from the previous step (a pending code, quote or
      // order) and send the user back when opened directly.
      const needsState = {
        AppRoute.otp,
        AppRoute.twofa,
        AppRoute.review,
        AppRoute.done,
        AppRoute.payconfirm,
        AppRoute.sending,
        AppRoute.celebrate,
        AppRoute.p2pdone,
      };
      if (needsState.contains(r)) continue;
      final path = router.routerDelegate.currentConfiguration.uri.path;
      expect(path, r.path.replaceAllMapped(RegExp(r':(\w+)'), (m) => r.sampleParams[m[1]]!), reason: r.name);
    }
  });

  testWidgets('limited account is sent to disabled from a gated screen', (tester) async {
    final container = await pumpApp(tester, session: const SessionState(signedIn: true, onboarded: true));
    container.read(routerProvider).goNamed(AppRoute.qswap.name);
    await tester.pumpAndSettle();
    final uri = container.read(routerProvider).routerDelegate.currentConfiguration.uri;
    expect(uri.path, AppRoute.disabled.path);
    expect(uri.queryParameters['from'], 'qswap');
  });

  testWidgets('renders in Hausa without missing framework localizations', (tester) async {
    final container = await pumpApp(tester, session: full);
    await container.read(localeSettingProvider.notifier).set(const Locale('ha'));
    container.read(routerProvider).goNamed(AppRoute.home.name);
    await tester.pumpAndSettle();
    expect(find.text('Gida'), findsOneWidget, reason: 'Home tab label in Hausa');

    container.read(sessionProvider.notifier).update(const SessionState(signedIn: true, onboarded: true));
    container.read(routerProvider).go(AppRoute.disabled.path);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
