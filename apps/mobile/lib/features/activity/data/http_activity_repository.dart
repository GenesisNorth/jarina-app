import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/core/api/live_resource.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina_core/jarina_core.dart';

/// [ActivityRepository] against `GET /v1/activity`: the newest page, fetched
/// again when the server announces new activity. Titles arrive localised.
class HttpActivityRepository implements ActivityRepository {
  HttpActivityRepository(this._api, this._realtime);

  final ApiClient _api;
  final RealtimeClient _realtime;

  @override
  Stream<List<Transaction>> watch() => liveResource(
    _realtime,
    'activity',
    () async => mapJson(
      await _api.get('activity'),
      (j) => [
        for (final item in j['items']! as List<Object?>) fromJson(item! as Map<String, Object?>),
      ],
    ),
  );

  static Transaction fromJson(Map<String, Object?> j) {
    final amount = j['amount']! as Map<String, Object?>;
    return Transaction(
      id: j['receiptId']! as String,
      category: TxCategory.values.byName(j['category']! as String),
      kind: TxKind.values.asNameMap()[j['kind']] ?? TxKind.bankTransfer,
      title: j['title']! as String,
      subtitle: j['subtitle']! as String,
      amount: Money.parse(amount['amount']! as String, Currency.fromCode(amount['currency']! as String)),
      createdAt: DateTime.parse(j['createdAt']! as String),
      status: TxStatus.values.byName(j['status']! as String),
      description: j['description'] as String?,
    );
  }
}
