import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum AssetKind { stock, crypto }

/// Colours and label for an asset's monogram badge (no third-party logos).
@immutable
class AssetBadgeStyle {
  const AssetBadgeStyle({required this.color, required this.ring, required this.ink, required this.label});

  factory AssetBadgeStyle.fromJson(Map<String, dynamic> j) => AssetBadgeStyle(
    color: _hex(j['color'] as String),
    ring: _hex(j['ring'] as String),
    ink: _hex(j['ink'] as String),
    label: j['label'] as String,
  );

  /// ARGB ints so the domain layer stays free of Flutter painting types.
  final int color;
  final int ring;
  final int ink;
  final String label;

  static int _hex(String h) => int.parse('FF${h.replaceFirst('#', '')}', radix: 16);
}

/// A tradable asset from the catalogue: an NGX stock or a crypto coin.
@immutable
class AssetInfo {
  const AssetInfo({
    required this.id,
    required this.name,
    required this.kind,
    required this.badge,
    required this.openPrice,
    this.sector,
    this.about,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> j) => AssetInfo(
    id: j['id'] as String,
    name: j['name'] as String,
    kind: j['type'] == 'stock' ? AssetKind.stock : AssetKind.crypto,
    sector: j['sector'] as String?,
    about: j['about'] as String?,
    badge: AssetBadgeStyle.fromJson(j['badge'] as Map<String, dynamic>),
    openPrice: Decimal.parse(j['price'] as String),
  );

  /// Ticker, e.g. `MTNN`, `BTC`.
  final String id;
  final String name;
  final AssetKind kind;
  final String? sector;
  final String? about;
  final AssetBadgeStyle badge;

  /// Price (NGN) at the start of the trading day.
  final Decimal openPrice;

  bool get isStock => kind == AssetKind.stock;

  /// Unit used for holdings: shares for stocks, the coin itself for crypto.
  Currency get unit => Currency.crypto(id, decimals: isStock ? 0 : 8);
}

/// Live price of one asset, in NGN.
@immutable
class Quote {
  const Quote({required this.assetId, required this.price, required this.changePct, required this.intraday});

  final String assetId;
  final Decimal price;

  /// Change since the day's open, in percent.
  final double changePct;

  /// Recent prices for sparklines (doubles are fine for drawing, never for money).
  final List<double> intraday;
}

enum ChartRange { day, week, month, year, all }

abstract interface class MarketRepository {
  Future<List<AssetInfo>> catalog();

  /// Emits the full quote map on every tick. Listening starts the feed;
  /// cancelling stops it, so screens only stream what they show.
  Stream<Map<String, Quote>> watchQuotes();

  /// Daily closes for longer ranges (week/month/year), oldest first.
  Future<List<double>> history(String assetId, ChartRange range);
}
