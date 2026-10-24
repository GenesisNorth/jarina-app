// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backupCodesLeft)
final backupCodesLeftProvider = BackupCodesLeftProvider._();

final class BackupCodesLeftProvider extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  BackupCodesLeftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupCodesLeftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupCodesLeftHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return backupCodesLeft(ref);
  }
}

String _$backupCodesLeftHash() => r'a3166a5b37eee421a80f425f3a998f11979d7868';

@ProviderFor(trustedDevices)
final trustedDevicesProvider = TrustedDevicesProvider._();

final class TrustedDevicesProvider
    extends $FunctionalProvider<AsyncValue<List<TrustedDevice>>, List<TrustedDevice>, FutureOr<List<TrustedDevice>>>
    with $FutureModifier<List<TrustedDevice>>, $FutureProvider<List<TrustedDevice>> {
  TrustedDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trustedDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trustedDevicesHash();

  @$internal
  @override
  $FutureProviderElement<List<TrustedDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TrustedDevice>> create(Ref ref) {
    return trustedDevices(ref);
  }
}

String _$trustedDevicesHash() => r'15094a2b92604ba00650b4957bf9245f9dd6879d';
