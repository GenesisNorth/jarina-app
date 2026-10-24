import 'package:flutter/foundation.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina_core/jarina_core.dart';

enum TradeSide { buy, sell }

/// A priced market order, shown on Review before the user confirms with PIN.
@immutable
class TradeQuote {
  const TradeQuote({
    required this.id,
    required this.asset,
    required this.side,
    required this.price,
    required this.quantity,
    required this.gross,
    required this.fee,
    required this.marketOpen,
    required this.expiresAt,
  });

  final String id;
  final AssetInfo asset;
  final TradeSide side;

  /// NGN per share/coin at quote time.
  final Decimal price;

  /// Whole shares for NGX stocks; up to 8 decimals for crypto.
  final Decimal quantity;

  /// Quantity × price.
  final Money gross;

  /// Jarina fee (2.5% of the order value).
  final Money fee;

  /// False for NGX orders placed out of hours: they queue for the next open.
  final bool marketOpen;
  final DateTime expiresAt;

  /// Buy: debited from the wallet. Sell: credited to it.
  Money get total => side == TradeSide.buy ? gross + fee : gross - fee;

  bool get isBuy => side == TradeSide.buy;
}

/// Asking to buy fewer than one whole NGX share.
final class BelowMinimumFailure extends Failure {
  const BelowMinimumFailure() : super('Below one share');
}

abstract interface class TradingRepository {
  /// Jarina's trade fee rate (0.025 = 2.5%). Server-configured.
  Decimal get feeRate;

  /// Buy with [spend] (before fee) from the home-currency wallet.
  Future<Result<TradeQuote>> quoteBuy(String assetId, Money spend);

  /// Sell [quantity] shares/coins into the home-currency wallet.
  Future<Result<TradeQuote>> quoteSell(String assetId, Decimal quantity);

  /// [pinToken] from the PIN step-up. Returns the order's transaction
  /// (pending if the market is closed).
  Future<Result<Transaction>> placeOrder(TradeQuote quote, {required String pinToken});
}
