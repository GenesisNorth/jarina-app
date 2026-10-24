import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';

import '../helpers.dart';

const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);

/// Screens that need state from a previous step bounce back when opened cold.
const Set<AppRoute> _skip = {
  AppRoute.otp, AppRoute.twofa, AppRoute.review, AppRoute.done, AppRoute.payconfirm, //
  AppRoute.sending, AppRoute.celebrate, AppRoute.p2pdone, AppRoute.dev, AppRoute.authpin, AppRoute.auth2fa,
};

SessionState _sessionFor(AppRoute r) => switch (r.group) {
  RouteGroup.preAuth => const SessionState(),
  RouteGroup.kyc => const SessionState(signedIn: true),
  _ => r == AppRoute.disabled ? const SessionState(signedIn: true, onboarded: true) : _full,
};

void main() {
  testWidgets('every screen fits a 360-wide phone at 200% text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = await pumpApp(tester, size: const Size(360, 780), session: _full);
    final router = c.read(routerProvider);
    final failures = <String>[];
    for (final r in AppRoute.values.where((r) => !_skip.contains(r))) {
      c.read(sessionProvider.notifier).update(_sessionFor(r));
      router.goNamed(r.name, pathParameters: r.sampleParams);
      await tester.pumpAndSettle();
      final e = tester.takeException();
      if (e != null) failures.add('${r.name}: $e');
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('tap targets are big enough and labelled; text has enough contrast', (tester) async {
    final handle = tester.ensureSemantics();
    final c = await pumpApp(tester, session: _full);
    final router = c.read(routerProvider);
    final failures = <String>[];
    for (final r in AppRoute.values.where((r) => !_skip.contains(r))) {
      c.read(sessionProvider.notifier).update(_sessionFor(r));
      router.goNamed(r.name, pathParameters: r.sampleParams);
      await tester.pumpAndSettle();
      for (final (name, g) in [
        ('tap-size', androidTapTargetGuideline),
        ('label', labeledTapTargetGuideline),
        ('contrast', textContrastGuideline),
      ]) {
        final result = await g.evaluate(tester);
        if (!result.passed) failures.add('${r.name} [$name]: ${result.reason}');
      }
    }
    handle.dispose();
    expect(failures, isEmpty, reason: failures.join('\n\n'));
  });

  testWidgets('every button can be pressed by a screen reader', (tester) async {
    final handle = tester.ensureSemantics();
    final c = await pumpApp(tester, session: _full);
    final router = c.read(routerProvider);
    final failures = <String>{};
    for (final r in AppRoute.values.where((r) => !_skip.contains(r))) {
      c.read(sessionProvider.notifier).update(_sessionFor(r));
      router.goNamed(r.name, pathParameters: r.sampleParams);
      await tester.pumpAndSettle();
      void visit(SemanticsNode n) {
        final d = n.getSemanticsData();
        final f = d.flagsCollection;
        if (f.isButton && f.isEnabled != Tristate.isFalse && !d.hasAction(SemanticsAction.tap) && !n.isInvisible) {
          failures.add('${r.name}: button "${d.label}" has no tap action');
        }
        n.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.semantics.find(find.byType(MaterialApp)).owner!.rootSemanticsNode!);
    }
    handle.dispose();
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
