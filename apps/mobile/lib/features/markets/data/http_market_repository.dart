import 'dart:async';

import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina_core/jarina_core.dart';

/// [MarketRepository] against the Jarina API: the catalogue and charts over
/// HTTP, live prices from `GET /v1/quotes` then the `quotes` socket topic.
class HttpMarketRepository implements MarketRepository {
  HttpMarketRepository(this._api, this._realtime);

  final ApiClient _api;
  final RealtimeClient _realtime;

  @override
  Future<List<AssetInfo>> catalog() async => switch (await _api.get('assets')) {
    Ok(value: final List<Object?> list) => [for (final a in list) AssetInfo.fromJson(a! as Map<String, dynamic>)],
    Ok() => throw const UnknownFailure('Unexpected response'),
    Err(:final failure) => throw apiFailure(failure),
  };

  /// The snapshot first, then every pushed update. Assets with no live price
  /// are absent (the screens already handle a missing quote). Cancelling
  /// stops at once (an `async*` loop would wait for the next push).
  @override
  Stream<Map<String, Quote>> watchQuotes() {
    StreamSubscription<Map<String, Object?>>? live;
    var pushed = false;
    late final StreamController<Map<String, Quote>> out;
    out = StreamController(
      onListen: () async {
        live = _realtime.topic('quotes').listen(
          (msg) {
            pushed = true;
            out.add(_quotes(msg['quotes']));
          },
          onError: out.addError,
        );
        final snapshot = await _api.get('quotes');
        // A push that arrived meanwhile is newer than the snapshot.
        if (!pushed && !out.isClosed) {
          if (snapshot case Ok(value: final Map<String, Object?> j)) out.add(_quotes(j['quotes']));
        }
      },
      onCancel: () => live?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<List<double>> history(String assetId, ChartRange range) async {
    final r = await _api.get('assets/${Uri.encodeComponent(assetId)}/history?range=${range.name}');
    return switch (mapJson(r, (j) => [for (final p in j['points']! as List<Object?>) (p! as num).toDouble()])) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  static Map<String, Quote> _quotes(Object? raw) => {
    for (final e in (raw as Map<String, Object?>? ?? const {}).entries)
      e.key: _quote(e.key, e.value! as Map<String, Object?>),
  };

  static Quote _quote(String id, Map<String, Object?> q) => Quote(
    assetId: id,
    price: Decimal.parse(q['price']! as String),
    open: Decimal.parse(q['open']! as String),
    changePct: (q['changePct']! as num).toDouble(),
    intraday: List.unmodifiable([for (final p in q['intraday']! as List<Object?>) (p! as num).toDouble()]),
  );
}
