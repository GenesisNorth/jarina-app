import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trading_state.g.dart';

/// Quote being reviewed (Trade → Review). Cleared once the order is placed.
@Riverpod(keepAlive: true)
class PendingTrade extends _$PendingTrade {
  @override
  TradeQuote? build() => null;

  // A method reads better at call sites than a setter here.
  // ignore: use_setters_to_change_properties
  void set(TradeQuote? q) => state = q;
}

/// The order just placed, for the confirmation screen.
@Riverpod(keepAlive: true)
class LastOrder extends _$LastOrder {
  @override
  (TradeQuote, Transaction)? build() => null;

  // ignore: use_setters_to_change_properties, same as PendingTrade.set.
  void set((TradeQuote, Transaction) order) => state = order;
}

/// Starred assets, stored on the device.
@Riverpod(keepAlive: true)
class Watchlist extends _$Watchlist {
  static const _key = 'watchlist';

  @override
  Set<String> build() => (ref.watch(sharedPreferencesProvider).getStringList(_key) ?? const []).toSet();

  Future<void> toggle(String id) async {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    await ref.read(sharedPreferencesProvider).setStringList(_key, state.toList());
  }
}

@riverpod
Future<List<double>> assetHistory(Ref ref, String assetId, ChartRange range) =>
    ref.watch(marketRepositoryProvider).history(assetId, range);
