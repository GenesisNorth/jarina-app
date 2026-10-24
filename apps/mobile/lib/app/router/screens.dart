import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/features/activity/presentation/activity_screen.dart';
import 'package:jarina/features/activity/presentation/receipt_screen.dart';
import 'package:jarina/features/dev/dev_index_screen.dart';
import 'package:jarina/features/home/presentation/home_screen.dart';
import 'package:jarina/features/kyc/presentation/address_screen.dart';
import 'package:jarina/features/kyc/presentation/details_screen.dart';
import 'package:jarina/features/kyc/presentation/disabled_screen.dart';
import 'package:jarina/features/kyc/presentation/identity_screen.dart';
import 'package:jarina/features/kyc/presentation/liveness_screen.dart';
import 'package:jarina/features/kyc/presentation/pin_screen.dart';
import 'package:jarina/features/kyc/presentation/twofa_setup_screen.dart';
import 'package:jarina/features/kyc/presentation/username_screen.dart';
import 'package:jarina/features/kyc/presentation/verified_screen.dart';
import 'package:jarina/features/onboarding/presentation/country_screen.dart';
import 'package:jarina/features/onboarding/presentation/language_screen.dart';
import 'package:jarina/features/onboarding/presentation/login_twofa_screen.dart';
import 'package:jarina/features/onboarding/presentation/otp_screen.dart';
import 'package:jarina/features/onboarding/presentation/phone_screen.dart';
import 'package:jarina/features/onboarding/presentation/welcome_screen.dart';
import 'package:jarina/features/wallets/presentation/add_money_screen.dart';
import 'package:jarina/features/wallets/presentation/convert_screen.dart';
import 'package:jarina/features/wallets/presentation/fiat_wallet_screen.dart';
import 'package:jarina/features/wallets/presentation/receive_screen.dart';
import 'package:jarina/features/wallets/presentation/wallets_screen.dart';
import 'package:jarina_core/jarina_core.dart';

/// The built screen for [route], or null while it is still a placeholder.
Widget? screenFor(AppRoute route, GoRouterState state) => switch (route) {
  AppRoute.welcome => const WelcomeScreen(),
  AppRoute.country => const CountryScreen(),
  AppRoute.langpick => const LanguageScreen(),
  AppRoute.phone => PhoneScreen(login: state.uri.queryParameters['mode'] == 'login'),
  AppRoute.otp => const OtpScreen(),
  AppRoute.twofa => const LoginTwofaScreen(),
  AppRoute.kyc1 => const DetailsScreen(),
  AppRoute.username => const UsernameScreen(),
  AppRoute.kyc2 => const IdentityScreen(),
  AppRoute.kyc3 => const LivenessScreen(),
  AppRoute.kyc4 => const AddressScreen(),
  AppRoute.kyc5 => const PinScreen(),
  AppRoute.kyc6 => const TwofaSetupScreen(),
  AppRoute.kycdone => const VerifiedScreen(),
  AppRoute.disabled => const DisabledScreen(),
  AppRoute.dev => const DevIndexScreen(),
  AppRoute.home => const HomeScreen(),
  AppRoute.wallets => const WalletsScreen(),
  AppRoute.activity => const ActivityScreen(),
  AppRoute.fiat => FiatWalletScreen(currency: _homeCurrency(state.pathParameters['currency'])),
  AppRoute.fiatadd => AddMoneyScreen(currency: _homeCurrency(state.pathParameters['currency'])),
  AppRoute.convert => ConvertScreen(from: _homeCurrency(state.uri.queryParameters['from'])),
  AppRoute.receive => const ReceiveScreen(),
  AppRoute.receipt => ReceiptScreen(id: state.pathParameters['id'] ?? ''),
  _ => null,
};

/// Unknown or non-home currencies in a deep link fall back to NGN.
Currency _homeCurrency(String? code) {
  final c = Currency.fromCode(code ?? 'NGN');
  return Currency.homeCurrencies.contains(c) ? c : Currency.ngn;
}
