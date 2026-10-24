import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/features/account/domain/profile.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repositories.g.dart';

@Riverpod(keepAlive: true)
FakeBackend fakeBackend(Ref ref) => FakeBackend(clock: ref.watch(clockProvider));

@Riverpod(keepAlive: true)
FakeLedger fakeLedger(Ref ref) {
  final ledger = FakeLedger(clock: ref.watch(clockProvider));
  ref.onDispose(ledger.dispose);
  return ledger;
}

/// Every repository is chosen here, so swapping fakes for the real API in the
/// backend phase is a change to this file only.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeBackendProvider) : throw _notYet('AuthRepository');

@Riverpod(keepAlive: true)
KycRepository kycRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeBackendProvider) : throw _notYet('KycRepository');

@Riverpod(keepAlive: true)
SecurityRepository securityRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeBackendProvider) : throw _notYet('SecurityRepository');

@Riverpod(keepAlive: true)
MarketRepository marketRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeLedgerProvider) : throw _notYet('MarketRepository');

@Riverpod(keepAlive: true)
WalletRepository walletRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeLedgerProvider) : throw _notYet('WalletRepository');

@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeLedgerProvider) : throw _notYet('ActivityRepository');

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeBackendProvider) : throw _notYet('ProfileRepository');

/// Refreshed after onboarding / account edits via `ref.invalidate(profileProvider)`.
@Riverpod(keepAlive: true)
Future<UserProfile> profile(Ref ref) => ref.watch(profileRepositoryProvider).me();

@Riverpod(keepAlive: true)
TradingRepository tradingRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeLedgerProvider) : throw _notYet('TradingRepository');

@Riverpod(keepAlive: true)
CryptoRepository cryptoRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeLedgerProvider) : throw _notYet('CryptoRepository');

StateError _notYet(String name) => StateError('$name has no API implementation yet (backend phase).');
