import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum TxCategory { stocks, crypto, transfers, bills }

enum TxKind { stockTrade, cryptoTrade, crossBorder, p2p, deposit, conversion, bill }

enum TxStatus { successful, pending, failed }

/// One entry in the unified activity feed, also the data behind a receipt.
@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.category,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    this.status = TxStatus.successful,
    this.counterparty,
    this.corridor,
    this.description,
  });

  /// 15-digit receipt id, e.g. `260911522889869`.
  final String id;
  final TxCategory category;
  final TxKind kind;

  /// Server-provided, already localised in production.
  final String title;
  final String subtitle;

  /// Signed: negative for money out.
  final Money amount;
  final DateTime createdAt;
  final TxStatus status;
  final String? counterparty;

  /// ISO country codes for cross-border payments: (source, destination).
  final (String, String)? corridor;
  final String? description;

  bool get isCredit => amount.isPositive;

  /// `260 911 522 889 869`
  String get formattedId => RegExp('.{1,3}').allMatches(id).map((m) => m[0]).join(' ');

  /// Deep link encoded in the receipt QR; the app verifies it against the server.
  Uri get verifyUri => Uri(scheme: 'jarina', host: 'verify', path: '/$id');
}

abstract interface class ActivityRepository {
  /// Newest first.
  Stream<List<Transaction>> watch();
}
