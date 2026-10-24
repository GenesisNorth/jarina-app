import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/app.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/shell/broken_screen.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrap(Env env) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash reporting (e.g. Sentry/Crashlytics) plugs into these two hooks once
  // the vendor is chosen. Never log balances, tokens or PINs.
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack, name: 'flutter');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log('$error', stackTrace: stack, name: 'uncaught');
    return true;
  };
  // Release builds show a calm fallback instead of the red error screen.
  if (kReleaseMode) ErrorWidget.builder = (details) => const BrokenScreen();

  final prefs = await SharedPreferences.getInstance();
  final store = SessionStore();
  // iOS keeps Keychain items after uninstall; drop them on a fresh install so
  // a reinstalled app doesn't sign in as the previous user.
  if (prefs.getBool('installed') != true) {
    await store.clear();
    await prefs.setBool('installed', true);
  }
  final session = await store.load();

  runApp(
    ProviderScope(
      overrides: [
        envProvider.overrideWithValue(env),
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionStoreProvider.overrideWithValue(store),
        initialSessionProvider.overrideWithValue(session),
      ],
      child: const JarinaApp(),
    ),
  );
}
