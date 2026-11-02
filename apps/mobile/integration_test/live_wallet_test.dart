import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jarina/app/env.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina_core/jarina_core.dart';

import '../test/flows/onboarding_flow_test.dart' show tapButton;
import '../test/helpers.dart';

/// The real naira wallet against a running local API (sandbox gateway):
/// funding account, a deposit through the webhook path, balance and activity.
///
/// ```sh
/// (cd ../../../jarina_backend && make dev)
/// flutter test integration_test/live_wallet_test.dart -d DEVICE_ID
/// ```
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const liveWallet = Env(
    flavor: Flavor.dev,
    apiBaseUrl: 'http://localhost:3100',
    useFakeData: true,
    liveApi: true,
    liveWallet: true,
  );

  Future<void> waitFor(WidgetTester tester, bool Function() done, String what, {int seconds = 15}) async {
    for (var i = 0; i < seconds * 10; i++) {
      if (done()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('Timed out waiting for $what');
  }

  testWidgets('add money: the server’s account, a deposit, the new balance and activity', (tester) async {
    final c = await pumpApp(tester, env: liveWallet);
    String loc() => c.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
    final phone = '+23490${List.generate(8, (_) => Random().nextInt(10)).join()}';

    // Sign in through the real API and give the account a KYC name.
    final auth = c.read(authRepositoryProvider);
    final sent = (await tester.runAsync(() => auth.sendOtp(phoneE164: phone, channel: OtpChannel.whatsapp)))!;
    final outcome = (await tester.runAsync(() => auth.verifyOtp(challengeId: sent.valueOrNull!.id, code: '123456')))!;
    await c.read(sessionProvider.notifier).signIn((outcome.valueOrNull! as SignedIn).session);
    await tester.runAsync(
      () => c
          .read(kycRepositoryProvider)
          .submitPersonalDetails(
            PersonalDetails(
              firstName: 'Aïssatou',
              lastName: 'Ɗanjuma',
              dateOfBirth: DateTime(1990, 5, 12),
              email: 'aissatou@example.com',
            ),
          ),
    );
    c.read(sessionProvider.notifier).update(const SessionState(signedIn: true, onboarded: true, twofaEnabled: true));
    await tester.pumpAndSettle();

    // The funding account comes from the server, in the KYC name.
    c.read(routerProvider).go('/fiatadd/NGN');
    await waitFor(tester, () => find.text('Jarina / Aïssatou Ɗanjuma').evaluate().isNotEmpty, 'the funding account');
    expect(find.text('Moniepoint MFB'), findsOneWidget);

    // A test deposit goes webhook → inbox → worker → ledger → socket.
    await tapButton(tester, 'Simulate a deposit · Test build only');
    await waitFor(tester, () => find.text('Test deposit added').evaluate().isNotEmpty, 'the deposit toast');
    final balances = c.read(walletRepositoryProvider).watchBalances();
    final credited = await tester.runAsync(
      () => balances
          .firstWhere((b) => b.fiatOf(Currency.ngn) == Money.parse('50000', Currency.ngn))
          .timeout(const Duration(seconds: 10)),
    );
    expect(credited, isNotNull);

    c.read(routerProvider).go('/more/activity');
    await waitFor(tester, () => find.text('Deposit · Bank transfer').evaluate().isNotEmpty, 'the deposit in activity');
    expect(loc(), '/more/activity');
  });
}
