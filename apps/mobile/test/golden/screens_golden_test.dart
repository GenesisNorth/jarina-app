@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/session/session_controller.dart';

import '../helpers.dart';

/// Pixel snapshots of key screens: light in EN/HA/FR, dark and a small phone
/// in English. Regenerate on macOS with `make goldens`.
const _full = SessionState(signedIn: true, onboarded: true, twofaEnabled: true);
final _now = DateTime.utc(2026, 10, 19, 10);

const _screens = <(String, String, SessionState)>[
  ('welcome', '/welcome', SessionState()),
  ('home', '/home', _full),
  ('stocks', '/stocks', _full),
  ('asset', '/asset/MTNN', _full),
  ('crypto', '/crypto', _full),
  ('transfer', '/home/transfer', _full),
  ('p2p', '/p2p', _full),
  ('more', '/more', _full),
  ('rule', '/rule?asset=DANGCEM', _full),
  ('account', '/account', _full),
];

Future<void> _loadFonts() async {
  final poppins = FontLoader('packages/jarina_ui/Poppins');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    poppins.addFont(rootBundle.load('packages/jarina_ui/fonts/Poppins-$w.ttf'));
  }
  await poppins.load();
  final fallback = FontLoader('packages/jarina_ui/JarinaFallback');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    fallback.addFont(rootBundle.load('packages/jarina_ui/fonts/JarinaFallback-$w.ttf'));
  }
  await fallback.load();
  await (FontLoader(
    'packages/jarina_ui/JarinaSymbols',
  )..addFont(rootBundle.load('packages/jarina_ui/fonts/JarinaSymbols-Regular.ttf'))).load();
  await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

void main() {
  setUpAll(_loadFonts);

  for (final (name, path, session) in _screens) {
    for (final (variant, size, lang, dark) in [
      ('en', const Size(390, 844), 'en', false),
      ('ha', const Size(390, 844), 'ha', false),
      ('fr', const Size(390, 844), 'fr', false),
      ('dark', const Size(390, 844), 'en', true),
      ('small', const Size(320, 568), 'en', false),
    ]) {
      testWidgets('$name · $variant', (tester) async {
        final c = await pumpApp(
          tester,
          session: session,
          size: size,
          clock: () => _now,
          prefs: {'locale': lang, 'theme_mode': dark ? ThemeMode.dark.name : ThemeMode.light.name},
        );
        expect(c.read(localeSettingProvider)?.languageCode, lang);
        c.read(routerProvider).go(path);
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.$variant.png'));
      });
    }
  }
}
