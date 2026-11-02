import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/core/fake/fake_automation.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/core/fake/fake_payments.dart';
import 'package:jarina/core/fake/fake_support.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/account/data/http_profile_repository.dart';
import 'package:jarina/features/account/domain/profile.dart';
import 'package:jarina/features/activity/data/http_activity_repository.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/auth/data/http_auth_repository.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/kyc/data/http_kyc_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/markets/data/http_market_repository.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina/features/security/data/http_security_repository.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/features/support/domain/support.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/data/http_wallet_repository.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repositories.g.dart';

@Riverpod(keepAlive: true)
FakeBackend fakeBackend(Ref ref) => FakeBackend(clock: ref.watch(clockProvider));

@Riverpod(keepAlive: true)
FakeLedger fakeLedger(Ref ref) {
  final liveMarkets = !ref.watch(envProvider).fakeMarkets;
  // With live markets, fake trades follow the real prices instead of simulating their own.
  final clock = ref.watch(clockProvider);
  final ledger = liveMarkets ? FakeLedger(clock: clock, tick: Duration.zero) : FakeLedger(clock: clock);
  if (liveMarkets) {
    final sub = ref.watch(marketRepositoryProvider).watchQuotes().listen(ledger.useLivePrices, onError: (_) {});
    ref.onDispose(sub.cancel);
  }
  ref.onDispose(ledger.dispose);
  return ledger;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) {
  final env = ref.watch(envProvider);
  final device = deviceId(ref.watch(sharedPreferencesProvider));
  final client = http.Client();
  ref.onDispose(client.close);
  return ApiClient(
    // Every route is versioned under /v1.
    baseUrl: Uri.parse('${env.apiBaseUrl}/v1/'),
    client: client,
    store: ref.watch(sessionStoreProvider),
    onSessionEnded: () => ref.read(sessionProvider.notifier).signOut(),
    headers: () => {
      'x-device-id': device,
      'x-device-platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      'x-device-name': defaultTargetPlatform == TargetPlatform.iOS ? 'iPhone' : 'Android phone',
      'accept-language':
          ref.read(localeSettingProvider)?.languageCode ?? PlatformDispatcher.instance.locale.languageCode,
    },
  );
}

@Riverpod(keepAlive: true)
RealtimeClient realtimeClient(Ref ref) {
  final env = ref.watch(envProvider);
  final api = ref.watch(apiClientProvider);
  final base = Uri.parse('${env.apiBaseUrl}/v1/ws');
  final client = RealtimeClient(
    url: base.replace(scheme: base.scheme == 'https' ? 'wss' : 'ws'),
    api: api,
    store: ref.watch(sessionStoreProvider),
    headers: api.headers,
  );
  ref.onDispose(client.dispose);
  return client;
}

/// Every repository is chosen here, so swapping fakes for the real API in the
/// backend phase is a change to this file only.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    ref.watch(envProvider).fakeAuth ? ref.watch(fakeBackendProvider) : HttpAuthRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
KycRepository kycRepository(Ref ref) {
  final env = ref.watch(envProvider);
  if (env.fakeAuth) return ref.watch(fakeBackendProvider);
  if (!env.useFakeData) throw _notYet('KycRepository');
  return HttpKycRepository(ref.watch(apiClientProvider), ref.watch(fakeBackendProvider));
}

@Riverpod(keepAlive: true)
SecurityRepository securityRepository(Ref ref) => ref.watch(envProvider).fakeAuth
    ? ref.watch(fakeBackendProvider)
    : HttpSecurityRepository(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
MarketRepository marketRepository(Ref ref) => ref.watch(envProvider).fakeMarkets
    ? ref.watch(fakeLedgerProvider)
    : HttpMarketRepository(ref.watch(apiClientProvider), ref.watch(realtimeClientProvider));

@Riverpod(keepAlive: true)
WalletRepository walletRepository(Ref ref) => ref.watch(envProvider).fakeWallet
    ? ref.watch(fakeLedgerProvider)
    : HttpWalletRepository(
        ref.watch(apiClientProvider),
        ref.watch(realtimeClientProvider),
        ref.watch(fakeLedgerProvider),
        clock: ref.watch(clockProvider),
      );

@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) => ref.watch(envProvider).fakeWallet
    ? ref.watch(fakeLedgerProvider)
    : HttpActivityRepository(ref.watch(apiClientProvider), ref.watch(realtimeClientProvider));

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ref.watch(envProvider).fakeAuth
    ? ref.watch(fakeBackendProvider)
    : HttpProfileRepository(ref.watch(apiClientProvider));

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
