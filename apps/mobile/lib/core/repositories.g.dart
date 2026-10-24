// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repositories.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fakeBackend)
final fakeBackendProvider = FakeBackendProvider._();

final class FakeBackendProvider extends $FunctionalProvider<FakeBackend, FakeBackend, FakeBackend>
    with $Provider<FakeBackend> {
  FakeBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakeBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakeBackendHash();

  @$internal
  @override
  $ProviderElement<FakeBackend> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FakeBackend create(Ref ref) {
    return fakeBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeBackend>(value),
    );
  }
}

String _$fakeBackendHash() => r'db2c29af9dca9993ff07c362ab343c827a0a1358';

@ProviderFor(fakeLedger)
final fakeLedgerProvider = FakeLedgerProvider._();

final class FakeLedgerProvider extends $FunctionalProvider<FakeLedger, FakeLedger, FakeLedger>
    with $Provider<FakeLedger> {
  FakeLedgerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakeLedgerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakeLedgerHash();

  @$internal
  @override
  $ProviderElement<FakeLedger> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FakeLedger create(Ref ref) {
    return fakeLedger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeLedger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeLedger>(value),
    );
  }
}

String _$fakeLedgerHash() => r'b7a27769a396a838764d7f0200f01af2583839c6';

/// Every repository is chosen here, so swapping fakes for the real API in the
/// backend phase is a change to this file only.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Every repository is chosen here, so swapping fakes for the real API in the
/// backend phase is a change to this file only.

final class AuthRepositoryProvider extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Every repository is chosen here, so swapping fakes for the real API in the
  /// backend phase is a change to this file only.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'873dd83856fc46e72fd2829429721afee63f6f2a';

@ProviderFor(kycRepository)
final kycRepositoryProvider = KycRepositoryProvider._();

final class KycRepositoryProvider extends $FunctionalProvider<KycRepository, KycRepository, KycRepository>
    with $Provider<KycRepository> {
  KycRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycRepositoryHash();

  @$internal
  @override
  $ProviderElement<KycRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  KycRepository create(Ref ref) {
    return kycRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycRepository>(value),
    );
  }
}

String _$kycRepositoryHash() => r'37ff776dd86c142edda8bddb118fe551a73f2ec6';

@ProviderFor(securityRepository)
final securityRepositoryProvider = SecurityRepositoryProvider._();

final class SecurityRepositoryProvider
    extends $FunctionalProvider<SecurityRepository, SecurityRepository, SecurityRepository>
    with $Provider<SecurityRepository> {
  SecurityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityRepositoryHash();

  @$internal
  @override
  $ProviderElement<SecurityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecurityRepository create(Ref ref) {
    return securityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityRepository>(value),
    );
  }
}

String _$securityRepositoryHash() => r'a4c0e74fd771e8ff6b2c7aaef0694e837ff4b2d3';

@ProviderFor(marketRepository)
final marketRepositoryProvider = MarketRepositoryProvider._();

final class MarketRepositoryProvider extends $FunctionalProvider<MarketRepository, MarketRepository, MarketRepository>
    with $Provider<MarketRepository> {
  MarketRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketRepositoryHash();

  @$internal
  @override
  $ProviderElement<MarketRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  MarketRepository create(Ref ref) {
    return marketRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarketRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarketRepository>(value),
    );
  }
}

String _$marketRepositoryHash() => r'0683f0b9da63ef55c9243fa0f24e33e0d8d3e963';

@ProviderFor(walletRepository)
final walletRepositoryProvider = WalletRepositoryProvider._();

final class WalletRepositoryProvider extends $FunctionalProvider<WalletRepository, WalletRepository, WalletRepository>
    with $Provider<WalletRepository> {
  WalletRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletRepositoryHash();

  @$internal
  @override
  $ProviderElement<WalletRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  WalletRepository create(Ref ref) {
    return walletRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletRepository>(value),
    );
  }
}

String _$walletRepositoryHash() => r'ee3df828c628c95b2ec778bf4f824a35329de8b6';

@ProviderFor(activityRepository)
final activityRepositoryProvider = ActivityRepositoryProvider._();

final class ActivityRepositoryProvider
    extends $FunctionalProvider<ActivityRepository, ActivityRepository, ActivityRepository>
    with $Provider<ActivityRepository> {
  ActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityRepositoryHash();

  @$internal
  @override
  $ProviderElement<ActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActivityRepository create(Ref ref) {
    return activityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityRepository>(value),
    );
  }
}

String _$activityRepositoryHash() => r'dd75462c2ab5e0647cd0407a905c1cf8ae46aa30';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends $FunctionalProvider<ProfileRepository, ProfileRepository, ProfileRepository>
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'3f03ca59734927f3f1cec45f604af9bc64efd811';

/// Refreshed after onboarding / account edits via `ref.invalidate(profileProvider)`.

@ProviderFor(profile)
final profileProvider = ProfileProvider._();

/// Refreshed after onboarding / account edits via `ref.invalidate(profileProvider)`.

final class ProfileProvider extends $FunctionalProvider<AsyncValue<UserProfile>, UserProfile, FutureOr<UserProfile>>
    with $FutureModifier<UserProfile>, $FutureProvider<UserProfile> {
  /// Refreshed after onboarding / account edits via `ref.invalidate(profileProvider)`.
  ProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  $FutureProviderElement<UserProfile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserProfile> create(Ref ref) {
    return profile(ref);
  }
}

String _$profileHash() => r'3f743d9ee253ea585b14ab199993bcd74f1e4b5c';

@ProviderFor(tradingRepository)
final tradingRepositoryProvider = TradingRepositoryProvider._();

final class TradingRepositoryProvider
    extends $FunctionalProvider<TradingRepository, TradingRepository, TradingRepository>
    with $Provider<TradingRepository> {
  TradingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tradingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tradingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TradingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TradingRepository create(Ref ref) {
    return tradingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradingRepository>(value),
    );
  }
}

String _$tradingRepositoryHash() => r'0864b3a190dc934ec628b3b99ce110aa7c616719';

@ProviderFor(cryptoRepository)
final cryptoRepositoryProvider = CryptoRepositoryProvider._();

final class CryptoRepositoryProvider extends $FunctionalProvider<CryptoRepository, CryptoRepository, CryptoRepository>
    with $Provider<CryptoRepository> {
  CryptoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cryptoRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cryptoRepositoryHash();

  @$internal
  @override
  $ProviderElement<CryptoRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  CryptoRepository create(Ref ref) {
    return cryptoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CryptoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CryptoRepository>(value),
    );
  }
}

String _$cryptoRepositoryHash() => r'e7e2f90c5ecfd2637b03bc7911976f6f26f462b2';

@ProviderFor(fakePayments)
final fakePaymentsProvider = FakePaymentsProvider._();

final class FakePaymentsProvider extends $FunctionalProvider<FakePayments, FakePayments, FakePayments>
    with $Provider<FakePayments> {
  FakePaymentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakePaymentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakePaymentsHash();

  @$internal
  @override
  $ProviderElement<FakePayments> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FakePayments create(Ref ref) {
    return fakePayments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakePayments value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakePayments>(value),
    );
  }
}

String _$fakePaymentsHash() => r'f4f319809114880206a777746a9e505e4c1286f3';

@ProviderFor(paymentsRepository)
final paymentsRepositoryProvider = PaymentsRepositoryProvider._();

final class PaymentsRepositoryProvider
    extends $FunctionalProvider<PaymentsRepository, PaymentsRepository, PaymentsRepository>
    with $Provider<PaymentsRepository> {
  PaymentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentsRepository create(Ref ref) {
    return paymentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentsRepository>(value),
    );
  }
}

String _$paymentsRepositoryHash() => r'84d641306f9c6a0cc1c43d2d5c1434a2e3edc7d4';

@ProviderFor(billsRepository)
final billsRepositoryProvider = BillsRepositoryProvider._();

final class BillsRepositoryProvider extends $FunctionalProvider<BillsRepository, BillsRepository, BillsRepository>
    with $Provider<BillsRepository> {
  BillsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billsRepositoryHash();

  @$internal
  @override
  $ProviderElement<BillsRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  BillsRepository create(Ref ref) {
    return billsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillsRepository>(value),
    );
  }
}

String _$billsRepositoryHash() => r'506cd6e490c09370aaa739b8ba9951301b178ef4';
