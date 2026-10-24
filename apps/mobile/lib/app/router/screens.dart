import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/features/activity/presentation/activity_screen.dart';
import 'package:jarina/features/activity/presentation/receipt_screen.dart';
import 'package:jarina/features/crypto/presentation/coin_screen.dart';
import 'package:jarina/features/crypto/presentation/crypto_lists_screens.dart';
import 'package:jarina/features/crypto/presentation/crypto_money_screens.dart';
import 'package:jarina/features/crypto/presentation/crypto_screen.dart';
import 'package:jarina/features/crypto/presentation/notifications_screen.dart';
import 'package:jarina/features/crypto/presentation/pro_trade_screen.dart';
import 'package:jarina/features/crypto/presentation/swap_screen.dart';
import 'package:jarina/features/crypto/presentation/withdraw_screen.dart';
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
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/country_screen.dart';
import 'package:jarina/features/onboarding/presentation/language_screen.dart';
import 'package:jarina/features/onboarding/presentation/login_twofa_screen.dart';
import 'package:jarina/features/onboarding/presentation/otp_screen.dart';
import 'package:jarina/features/onboarding/presentation/phone_screen.dart';
import 'package:jarina/features/onboarding/presentation/welcome_screen.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/trading/presentation/asset_screen.dart';
import 'package:jarina/features/trading/presentation/order_done_screen.dart';
import 'package:jarina/features/trading/presentation/picker_screen.dart';
import 'package:jarina/features/trading/presentation/review_screen.dart';
import 'package:jarina/features/trading/presentation/stocks_screen.dart';
import 'package:jarina/features/trading/presentation/trade_screen.dart';
import 'package:jarina/features/wallets/presentation/add_money_screen.dart';
import 'package:jarina/features/wallets/presentation/convert_screen.dart';
import 'package:jarina/features/wallets/presentation/fiat_wallet_screen.dart';
import 'package:jarina/features/wallets/presentation/receive_screen.dart';
import 'package:jarina/features/wallets/presentation/wallets_screen.dart';
import 'package:jarina_core/jarina_core.dart';

/// The built screen for [route], or null while it is still a placeholder.
///
/// Screens with parameters are keyed by their URI so moving between, say,
/// /qcoin/USDT and /qcoin/XRP never carries state (like a deposit address)
/// from one to the other.
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
  AppRoute.fiat => FiatWalletScreen(
    key: ValueKey(state.uri),
    currency: _homeCurrency(state.pathParameters['currency']),
  ),
  AppRoute.fiatadd => AddMoneyScreen(
    key: ValueKey(state.uri),
    currency: _homeCurrency(state.pathParameters['currency']),
  ),
  AppRoute.convert => ConvertScreen(from: _homeCurrency(state.uri.queryParameters['from'])),
  AppRoute.receive => const ReceiveScreen(),
  AppRoute.receipt => ReceiptScreen(key: ValueKey(state.uri), id: state.pathParameters['id'] ?? ''),
  AppRoute.stocks => const StocksScreen(),
  AppRoute.asset => AssetScreen(key: ValueKey(state.uri), assetId: state.pathParameters['id'] ?? ''),
  AppRoute.entry => TradeScreen(
    key: ValueKey(state.uri),
    assetId: state.uri.queryParameters['asset'] ?? 'MTNN',
    side: state.uri.queryParameters['side'] == 'sell' ? TradeSide.sell : TradeSide.buy,
  ),
  AppRoute.picker => PickerScreen(
    kind: switch (state.uri.queryParameters['kind']) {
      'stocks' => AssetKind.stock,
      'crypto' => AssetKind.crypto,
      _ => null,
    },
    side: state.uri.queryParameters['side'] == 'sell' ? TradeSide.sell : TradeSide.buy,
  ),
  AppRoute.review => const ReviewScreen(),
  AppRoute.done => const OrderDoneScreen(),
  AppRoute.crypto => const CryptoScreen(),
  AppRoute.qcoin => CoinScreen(key: ValueKey(state.uri), coin: state.pathParameters['coin'] ?? 'USDT'),
  AppRoute.usdt => const CoinScreen(coin: 'USDT'),
  AppRoute.qwallets => const CryptoWalletsScreen(),
  AppRoute.qswap => SwapScreen(
    key: ValueKey(state.uri),
    from: state.uri.queryParameters['from'] ?? 'USDT',
    to: state.uri.queryParameters['to'] ?? 'BTC',
  ),
  AppRoute.qwd => WithdrawScreen(key: ValueKey(state.uri), coin: state.uri.queryParameters['coin'] ?? 'USDT'),
  AppRoute.qhist => const CryptoHistoryScreen(),
  AppRoute.qorders => const OrdersScreen(),
  AppRoute.qpro => ProTradeScreen(key: ValueKey(state.uri), coin: state.uri.queryParameters['coin'] ?? 'BTC'),
  AppRoute.qbuy => const BuyCryptoScreen(),
  AppRoute.qcashout => const CashOutScreen(),
  AppRoute.qauto => const AutoSwapScreen(),
  AppRoute.qloan => const LoanScreen(),
  AppRoute.qnotif => const NotificationsScreen(),
  _ => null,
};

/// Unknown or non-home currencies in a deep link fall back to NGN.
Currency _homeCurrency(String? code) {
  final c = Currency.fromCode(code ?? 'NGN');
  return Currency.homeCurrencies.contains(c) ? c : Currency.ngn;
}
