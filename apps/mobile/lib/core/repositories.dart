import 'package:jarina/core/fake/fake_automation.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/fake/fake_payments.dart';
import 'package:jarina/core/fake/fake_support.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/features/account/domain/profile.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/features/support/domain/support.dart';
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

@Riverpod(keepAlive: true)
FakePayments fakePayments(Ref ref) =>
    FakePayments(ref.watch(fakeLedgerProvider), latency: ref.watch(fakeLedgerProvider).latency);

@Riverpod(keepAlive: true)
PaymentsRepository paymentsRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakePaymentsProvider) : throw _notYet('PaymentsRepository');

@Riverpod(keepAlive: true)
BillsRepository billsRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakePaymentsProvider) : throw _notYet('BillsRepository');

@Riverpod(keepAlive: true)
FakeAutomation fakeAutomation(Ref ref) {
  final ledger = ref.watch(fakeLedgerProvider);
  final automation = FakeAutomation(ledger, latency: ledger.latency);
  ref.onDispose(automation.dispose);
  return automation;
}

@Riverpod(keepAlive: true)
AutomationRepository automationRepository(Ref ref) =>
    ref.watch(envProvider).useFakeData ? ref.watch(fakeAutomationProvider) : throw _notYet('AutomationRepository');

@Riverpod(keepAlive: true)
SupportRepository supportRepository(Ref ref) {
  if (!ref.watch(envProvider).useFakeData) throw _notYet('SupportRepository');
  final latency = ref.watch(fakeLedgerProvider).latency;
  final support = FakeSupport(
    clock: ref.watch(clockProvider),
    replyDelay: latency == Duration.zero ? Duration.zero : const Duration(milliseconds: 1100),
  );
  ref.onDispose(support.dispose);
  return support;
}

StateError _notYet(String name) => StateError('$name has no API implementation yet (backend phase).');
