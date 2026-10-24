// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeModeSetting)
final themeModeSettingProvider = ThemeModeSettingProvider._();

final class ThemeModeSettingProvider extends $NotifierProvider<ThemeModeSetting, ThemeMode> {
  ThemeModeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeSettingHash();

  @$internal
  @override
  ThemeModeSetting create() => ThemeModeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeSettingHash() => r'167132373de0570c89a89299ad64fdc655bfc4dc';

abstract class _$ThemeModeSetting extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<ThemeMode, ThemeMode>, ThemeMode, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LocaleSetting)
final localeSettingProvider = LocaleSettingProvider._();

final class LocaleSettingProvider extends $NotifierProvider<LocaleSetting, Locale?> {
  LocaleSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeSettingHash();

  @$internal
  @override
  LocaleSetting create() => LocaleSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeSettingHash() => r'6fcd37bb83472b1c034a399ce0937369599c7a00';

abstract class _$LocaleSetting extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<Locale?, Locale?>, Locale?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Approve small payments with Face ID / fingerprint instead of the PIN.
/// Stored on the device; the server still enforces its own limits.

@ProviderFor(BiometricsSetting)
final biometricsSettingProvider = BiometricsSettingProvider._();

/// Approve small payments with Face ID / fingerprint instead of the PIN.
/// Stored on the device; the server still enforces its own limits.
final class BiometricsSettingProvider extends $NotifierProvider<BiometricsSetting, bool> {
  /// Approve small payments with Face ID / fingerprint instead of the PIN.
  /// Stored on the device; the server still enforces its own limits.
  BiometricsSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricsSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricsSettingHash();

  @$internal
  @override
  BiometricsSetting create() => BiometricsSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricsSettingHash() => r'54371c0776c3e211c58d10be82d7f37b8234244a';

/// Approve small payments with Face ID / fingerprint instead of the PIN.
/// Stored on the device; the server still enforces its own limits.

abstract class _$BiometricsSetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
