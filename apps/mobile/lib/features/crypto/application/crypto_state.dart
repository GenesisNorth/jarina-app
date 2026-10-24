import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crypto_state.g.dart';

@Riverpod(keepAlive: true)
Stream<List<CryptoTransfer>> cryptoTransfers(Ref ref) => ref.watch(cryptoRepositoryProvider).watchTransfers();

@Riverpod(keepAlive: true)
Stream<List<LimitOrder>> cryptoOrders(Ref ref) => ref.watch(cryptoRepositoryProvider).watchOrders();

@Riverpod(keepAlive: true)
Stream<String?> autoSwapTarget(Ref ref) => ref.watch(cryptoRepositoryProvider).watchAutoSwapTarget();

@Riverpod(keepAlive: true)
Future<List<CryptoNetwork>> coinNetworks(Ref ref, String coin) => ref.watch(cryptoRepositoryProvider).networks(coin);

/// When the user last opened Notifications; newer items count as unread.
@Riverpod(keepAlive: true)
class NotificationsReadAt extends _$NotificationsReadAt {
  static const _key = 'notifications.readAt';

  @override
  DateTime? build() {
    final ms = ref.watch(sharedPreferencesProvider).getInt(_key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markAllRead() async {
    final now = ref.read(clockProvider)();
    state = now;
    await ref.read(sharedPreferencesProvider).setInt(_key, now.millisecondsSinceEpoch);
  }
}

/// Coin still reserved by open sell orders ("In open orders").
Decimal reservedInOrders(List<LimitOrder> orders, String coin) {
  var sum = Decimal.zero;
  for (final o in orders) {
    final open = o.status == OrderStatus.open || o.status == OrderStatus.partiallyFilled;
    if (o.coin == coin && o.side == OrderSide.sell && open) {
      sum += o.amount * Decimal.parse((1 - o.filled).toStringAsFixed(4));
    }
  }
  return sum;
}
