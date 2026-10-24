// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_security.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lock a signed-in app on launch. Tests and screenshot runs turn it off.

@ProviderFor(lockOnLaunch)
final lockOnLaunchProvider = LockOnLaunchProvider._();

/// Lock a signed-in app on launch. Tests and screenshot runs turn it off.

final class LockOnLaunchProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Lock a signed-in app on launch. Tests and screenshot runs turn it off.
  LockOnLaunchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockOnLaunchProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockOnLaunchHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return lockOnLaunch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$lockOnLaunchHash() => r'ccc1c514f22123010ecf3a58bf9eca9b04c2b2d9';

/// Whether the PIN lock screen covers the app.

@ProviderFor(AppLock)
final appLockProvider = AppLockProvider._();

/// Whether the PIN lock screen covers the app.
final class AppLockProvider extends $NotifierProvider<AppLock, bool> {
  /// Whether the PIN lock screen covers the app.
  AppLockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockHash();

  @$internal
  @override
  AppLock create() => AppLock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLockHash() => r'fc9655dd3dc9c8d943e5ed209762d038c97840ad';

/// Whether the PIN lock screen covers the app.

abstract class _$AppLock extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Best-effort root / jailbreak signal from the platform (false when unknown).

@ProviderFor(deviceCompromised)
final deviceCompromisedProvider = DeviceCompromisedProvider._();

/// Best-effort root / jailbreak signal from the platform (false when unknown).

final class DeviceCompromisedProvider extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Best-effort root / jailbreak signal from the platform (false when unknown).
  DeviceCompromisedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceCompromisedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceCompromisedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return deviceCompromised(ref);
  }
}

String _$deviceCompromisedHash() => r'ef7b032a80b4d91de6b1200b9dfda96a96792cb4';

/// The user has seen the rooted-device warning on this install.

@ProviderFor(CompromisedWarningSeen)
final compromisedWarningSeenProvider = CompromisedWarningSeenProvider._();

/// The user has seen the rooted-device warning on this install.
final class CompromisedWarningSeenProvider extends $NotifierProvider<CompromisedWarningSeen, bool> {
  /// The user has seen the rooted-device warning on this install.
  CompromisedWarningSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'compromisedWarningSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$compromisedWarningSeenHash();

  @$internal
  @override
  CompromisedWarningSeen create() => CompromisedWarningSeen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$compromisedWarningSeenHash() => r'c12967dc674525b2389c8e87f2673a1fec4ccdf2';

/// The user has seen the rooted-device warning on this install.

abstract class _$CompromisedWarningSeen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
