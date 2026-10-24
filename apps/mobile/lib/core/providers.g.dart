// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `bootstrap()`.

@ProviderFor(env)
final envProvider = EnvProvider._();

/// Overridden in `bootstrap()`.

final class EnvProvider extends $FunctionalProvider<Env, Env, Env> with $Provider<Env> {
  /// Overridden in `bootstrap()`.
  EnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envHash();

  @$internal
  @override
  $ProviderElement<Env> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Env create(Ref ref) {
    return env(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Env value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Env>(value),
    );
  }
}

String _$envHash() => r'be1af9d8e3a609df83d05a3a99a75618063a8830';

/// Overridden in `bootstrap()` after the instance is loaded.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Overridden in `bootstrap()` after the instance is loaded.

final class SharedPreferencesProvider
    extends $FunctionalProvider<SharedPreferences, SharedPreferences, SharedPreferences>
    with $Provider<SharedPreferences> {
  /// Overridden in `bootstrap()` after the instance is loaded.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'ddecb5b641e78760b25c7357d4ec4c5bb04b9c89';
