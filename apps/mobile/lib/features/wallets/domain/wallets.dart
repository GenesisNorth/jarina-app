import 'package:flutter/foundation.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina_core/jarina_core.dart';

/// Balances across every wallet the user holds.
@immutable
class Balances {
  const Balances({required this.fiat, required this.holdings});

  /// Home-currency wallets (NGN, GHS, XOF, XAF).
  final Map<Currency, Money> fiat;

  /// Asset id → quantity (shares or coins).
  final Map<String, Decimal> holdings;

  Money fiatOf(Currency c) => fiat[c] ?? Money.zero(c);
  Decimal qtyOf(String assetId) => holdings[assetId] ?? Decimal.zero;
}

/// Exchange rates expressed as units of a currency per 1 NGN.
@immutable
class FxRates {
  const FxRates(this.perNgn);

  final Map<Currency, Decimal> perNgn;

  /// Converts via NGN, rounded to the target currency's precision.
  Money convert(Money m, Currency to) {
    if (m.currency == to) return m;
    final fromRate = perNgn[m.currency];
    final toRate = perNgn[to];
    if (fromRate == null || toRate == null) throw ArgumentError('No rate for ${m.currency} → $to');
    final ngn = (m.amount / fromRate).toDecimal(scaleOnInfinitePrecision: 12);
    return Money(ngn * toRate, to).rounded();
  }

  /// Units of [to] for 1 [from].
  Decimal rate(Currency from, Currency to) => (perNgn[to]! / perNgn[from]!).toDecimal(scaleOnInfinitePrecision: 8);
}

/// Static facts about a home-currency wallet.
@immutable
class FiatWalletInfo {
  const FiatWalletInfo({required this.currency, required this.countryIso, required this.rails});

  final Currency currency;

  /// Flag shown on the wallet (CFA wallets use a representative country).
  final String countryIso;

  /// How the user can fund it, e.g. "Bank transfer (NIP)".
  final List<String> rails;

  static const all = [
    FiatWalletInfo(currency: Currency.ngn, countryIso: 'NG', rails: ['Bank transfer (NIP)', 'USSD', 'Agent cash-in']),
    FiatWalletInfo(
      currency: Currency.ghs,
      countryIso: 'GH',
      rails: ['Mobile money (MoMo)', 'Bank transfer (GhIPSS)', 'Agent cash-in'],
    ),
    FiatWalletInfo(currency: Currency.xof, countryIso: 'NE', rails: ['Mobile money', 'Bank transfer', 'Agent cash-in']),
    FiatWalletInfo(currency: Currency.xaf, countryIso: 'CM', rails: ['Mobile money', 'Bank transfer', 'Agent cash-in']),
  ];

  static FiatWalletInfo of(Currency c) => all.firstWhere((w) => w.currency == c);
}

/// Dedicated account the user pays into to fund a wallet.
@immutable
class FundingAccount {
  const FundingAccount({required this.accountName, required this.accountNumber, required this.bankName});

  final String accountName;
  final String accountNumber;
  final String bankName;
}

@immutable
class PaymentRequest {
  const PaymentRequest({
    required this.id,
    required this.fromName,
    required this.fromHandle,
    required this.amount,
    this.note,
  });

  final String id;
  final String fromName;
  final String fromHandle;
  final Money amount;
  final String? note;
}

/// A priced conversion, valid until [expiresAt].
@immutable
class ConvertQuote {
  const ConvertQuote({
    required this.id,
    required this.from,
    required this.receive,
    required this.fee,
    required this.rate,
    required this.expiresAt,
  });

  final String id;
  final Money from;

  /// What lands in the target wallet, after the fee.
  final Money receive;
  final Money fee;
  final Decimal rate;
  final DateTime expiresAt;
}

abstract interface class WalletRepository {
  Stream<Balances> watchBalances();

  Future<FxRates> rates();

  Future<Result<FundingAccount>> fundingAccount(Currency currency);

  Future<Result<ConvertQuote>> quoteConvert(Money from, Currency to);

  /// [pinToken] comes from a successful PIN step-up.
  Future<Result<Transaction>> convert(ConvertQuote quote, {required String pinToken});

  Stream<List<PaymentRequest>> watchRequests();

  Future<Result<void>> declineRequest(String id);

  Future<Result<Transaction>> payRequest(String id, {required String pinToken});

  /// Test builds only: credits a wallet as if a bank transfer landed.
  Future<Result<Transaction>> simulateDeposit(Money amount);
}
