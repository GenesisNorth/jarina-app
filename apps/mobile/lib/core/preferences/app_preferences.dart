import 'package:flutter/material.dart';
import 'package:jarina/core/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_preferences.g.dart';

/// Locales the app ships. Hausa needs the fallback delegates in
/// `l10n/fallback_localizations.dart`.
const supportedLocales = [Locale('en'), Locale('ha'), Locale('fr')];

@Riverpod(keepAlive: true)
class ThemeModeSetting extends _$ThemeModeSetting {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

@Riverpod(keepAlive: true)
class LocaleSetting extends _$LocaleSetting {
  static const _key = 'locale';

  /// `null` follows the device locale (falling back to English).
  @override
  Locale? build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return saved == null ? null : Locale(saved);
  }

  Future<void> set(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_key, locale.languageCode);
  }
}

/// Approve small payments with Face ID / fingerprint instead of the PIN.
/// Stored on the device; the server still enforces its own limits.
@Riverpod(keepAlive: true)
class BiometricsSetting extends _$BiometricsSetting {
  static const _key = 'biometrics';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set({required bool enabled}) async {
    state = enabled;
    await ref.read(sharedPreferencesProvider).setBool(_key, enabled);
  }
}
