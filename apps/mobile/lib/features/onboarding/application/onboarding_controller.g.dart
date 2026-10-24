// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Onboarding)
final onboardingProvider = OnboardingProvider._();

final class OnboardingProvider extends $NotifierProvider<Onboarding, OnboardingState> {
  OnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingHash();

  @$internal
  @override
  Onboarding create() => Onboarding();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingHash() => r'055cb4cbaae1023d26d48e0c7d0e6ed534f02e61';

abstract class _$Onboarding extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<OnboardingState, OnboardingState>, OnboardingState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// The chosen country, defaulting to Nigeria (largest market) when unset.

@ProviderFor(selectedCountry)
final selectedCountryProvider = SelectedCountryProvider._();

/// The chosen country, defaulting to Nigeria (largest market) when unset.

final class SelectedCountryProvider extends $FunctionalProvider<AsyncValue<Country>, Country, FutureOr<Country>>
    with $FutureModifier<Country>, $FutureProvider<Country> {
  /// The chosen country, defaulting to Nigeria (largest market) when unset.
  SelectedCountryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCountryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCountryHash();

  @$internal
  @override
  $FutureProviderElement<Country> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Country> create(Ref ref) {
    return selectedCountry(ref);
  }
}

String _$selectedCountryHash() => r'280562103c5cc796ea257c09f812389771469be6';

@ProviderFor(KycDraftStore)
final kycDraftStoreProvider = KycDraftStoreProvider._();

final class KycDraftStoreProvider extends $NotifierProvider<KycDraftStore, KycDraft> {
  KycDraftStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycDraftStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycDraftStoreHash();

  @$internal
  @override
  KycDraftStore create() => KycDraftStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycDraft>(value),
    );
  }
}

String _$kycDraftStoreHash() => r'21e9ffe775abd4fc83d7f6d7c18e70b5b137d8d2';

abstract class _$KycDraftStore extends $Notifier<KycDraft> {
  KycDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<KycDraft, KycDraft>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<KycDraft, KycDraft>, KycDraft, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
