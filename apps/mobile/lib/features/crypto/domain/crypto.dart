import 'package:flutter/foundation.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina_core/jarina_core.dart';

/// A blockchain network a coin can move on (TRC-20, ERC-20…).
@immutable
class CryptoNetwork {
  const CryptoNetwork({required this.id, required this.name, required this.withdrawFee, required this.memoRequired});

  factory CryptoNetwork.fromJson(Map<String, dynamic> j) => CryptoNetwork(
    id: j['id'] as String,
    name: j['name'] as String,
    withdrawFee: Decimal.parse(j['withdrawFee'] as String),
    memoRequired: j['memo'] as bool,
  );

  /// Short id shown on chips: `TRC-20`.
  final String id;

  /// `TRON`
  final String name;

  /// Network fee charged on withdrawals, in the coin.
  final Decimal withdrawFee;

  /// XRP, XLM, TON: deposits need the memo/tag or they can't be credited.
  final bool memoRequired;

  /// `TRON · TRC-20`, or just the name when they match (`Bitcoin`).
  String get label => name == id ? name : '$name · $id';
}

@immutable
class DepositAddress {
  const DepositAddress({required this.coin, required this.network, required this.address, this.memo});

  final String coin;
  final CryptoNetwork network;
  final String address;
  final String? memo;
}

/// Instant swap between any two of NGN and the coins. Valid ~15 seconds.
@immutable
class SwapQuote {
  const SwapQuote({
    required this.id,
    required this.pay,
    required this.receive,
    required this.fee,
    required this.rate,
    required this.expiresAt,
  });

  final String id;
  final Money pay;
  final Money receive;

  /// Jarina fee, in NGN.
  final Money fee;

  /// Units of the receive asset per one unit of the pay asset.
  final Decimal rate;
  final DateTime expiresAt;
}

enum TransferDirection { deposit, withdrawal }

enum TransferStatus { confirming, processing, successful, onHold, rejected, cancelled }

/// An on-chain deposit or withdrawal (or an internal transfer to a Jarina user).
@immutable
class CryptoTransfer {
  const CryptoTransfer({
    required this.id,
    required this.coin,
    required this.direction,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.network,
    this.address,
    this.confirmations,
    this.requiredConfirmations,
    this.note,
    this.toUser,
  });

  final String id;
  final String coin;
  final TransferDirection direction;
  final Decimal amount;
  final TransferStatus status;
  final DateTime createdAt;
  final String? network;
  final String? address;
  final int? confirmations;
  final int? requiredConfirmations;

  /// Why a transfer is on hold or rejected.
  final String? note;

  /// @username for free internal transfers.
  final String? toUser;

  bool get cancellable => direction == TransferDirection.withdrawal && status == TransferStatus.processing;

  CryptoTransfer copyWith({TransferStatus? status}) => CryptoTransfer(
    id: id,
    coin: coin,
    direction: direction,
    amount: amount,
    status: status ?? this.status,
    createdAt: createdAt,
    network: network,
    address: address,
    confirmations: confirmations,
    requiredConfirmations: requiredConfirmations,
    note: note,
    toUser: toUser,
  );
}

enum OrderSide { buy, sell }

enum OrderType { limit, market }

enum OrderStatus { open, partiallyFilled, filled, cancelled }

/// A pro-trade order on a coin/NGN pair.
@immutable
class LimitOrder {
  const LimitOrder({
    required this.id,
    required this.coin,
    required this.side,
    required this.type,
    required this.price,
    required this.amount,
    required this.filled,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String coin;
  final OrderSide side;
  final OrderType type;

  /// NGN per coin.
  final Decimal price;

  /// Coin amount.
  final Decimal amount;

  /// 0..1 fraction filled.
  final double filled;
  final OrderStatus status;
  final DateTime createdAt;

  String get pair => '$coin/NGN';

  LimitOrder copyWith({OrderStatus? status}) => LimitOrder(
    id: id,
    coin: coin,
    side: side,
    type: type,
    price: price,
    amount: amount,
    filled: filled,
    status: status ?? this.status,
    createdAt: createdAt,
  );
}

@immutable
class LoanQuote {
  const LoanQuote({
    required this.collateral,
    required this.ltv,
    required this.days,
    required this.borrow,
    required this.interest,
    required this.liquidationPrice,
  });

  final Money collateral;

  /// Loan-to-value, 0..1.
  final double ltv;
  final int days;

  /// NGN credited to the Naira wallet.
  final Money borrow;
  final Money interest;

  /// NGN price per coin at which the collateral is sold.
  final Money liquidationPrice;

  Money get totalToRepay => borrow + interest;
}

@immutable
class BankAccount {
  const BankAccount({required this.bank, required this.number, required this.name});

  final String bank;
  final String number;

  /// Name returned by the bank lookup (NIP name enquiry).
  final String name;
}

/// A "@handle not found" style failure for internal transfers.
final class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('User not found');
}

final class InvalidAddressFailure extends Failure {
  const InvalidAddressFailure() : super('Invalid address');
}

abstract interface class CryptoRepository {
  /// Networks each coin can be deposited/withdrawn on (server-configured).
  Future<List<CryptoNetwork>> networks(String coin);

  /// A deposit address. [fresh] issues a new one (old ones keep working).
  Future<Result<DepositAddress>> depositAddress(String coin, CryptoNetwork network, {bool fresh = false});

  /// Swap [pay] into [to] (NGN or a coin code). 2.5% fee.
  Future<Result<SwapQuote>> quoteSwap(Money pay, String to);

  Future<Result<Transaction>> swap(SwapQuote quote, {required String pinToken});

  /// [twofaToken] is required: withdrawals always need 2FA.
  Future<Result<CryptoTransfer>> withdraw({
    required String coin,
    required CryptoNetwork network,
    required String address,
    required Decimal amount,
    required String pinToken,
    required String twofaToken,
    String? memo,
  });

  /// Free, instant transfer to another Jarina user.
  Future<Result<CryptoTransfer>> sendToUser({
    required String coin,
    required String username,
    required Decimal amount,
    required String pinToken,
    required String twofaToken,
  });

  Stream<List<CryptoTransfer>> watchTransfers();

  Future<Result<void>> cancelWithdrawal(String id);

  Stream<List<LimitOrder>> watchOrders();

  Future<Result<LimitOrder>> placeLimitOrder({
    required String coin,
    required OrderSide side,
    required Decimal price,
    required Decimal amount,
    required String pinToken,
  });

  Future<Result<void>> cancelOrder(String id);

  /// Banks for cash-out, and NIP name enquiry on an account number.
  List<String> banks();

  Future<Result<BankAccount>> resolveAccount(String bank, String number);

  /// Sell [amount] of a coin and pay the Naira to a bank account.
  Future<Result<Transaction>> cashOut({
    required Money amount,
    required BankAccount account,
    required String pinToken,
    required String twofaToken,
  });

  Future<Result<LoanQuote>> quoteLoan(Money collateral, {required double ltv, required int days});

  Future<Result<Transaction>> takeLoan(LoanQuote quote, {required String pinToken});

  /// Auto-swap: convert incoming crypto deposits to the target on arrival.
  Stream<String?> watchAutoSwapTarget();

  Future<void> setAutoSwap(String? target);
}
