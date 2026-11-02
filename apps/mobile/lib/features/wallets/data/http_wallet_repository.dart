import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/core/api/failures.dart';
import 'package:jarina/core/api/live_resource.dart';
import 'package:jarina/core/api/realtime_client.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina_core/jarina_core.dart';

/// [WalletRepository] against the Jarina API. Payment requests stay with
/// [_pending] until P2P lands (backend phase B9).
class HttpWalletRepository implements WalletRepository {
  HttpWalletRepository(this._api, this._realtime, this._pending, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final ApiClient _api;
  final RealtimeClient _realtime;
  final WalletRepository _pending;
  final DateTime Function() _now;

  @override
  Stream<Balances> watchBalances() => liveResource(
    _realtime,
    'balances',
    () async => mapJson(await _api.get('balances'), (j) {
      final fiat = j['fiat']! as Map<String, Object?>;
      final holdings = j['holdings']! as Map<String, Object?>;
      return Balances(
        fiat: {
          for (final e in fiat.entries)
            if (_fiat(e.key) case final c?) c: Money.parse(e.value! as String, c),
        },
        holdings: {for (final e in holdings.entries) e.key: Decimal.parse(e.value! as String)},
      );
    }),
  );

  @override
  Future<FxRates> rates() async {
    final r = mapJson(await _api.get('fx'), (j) {
      final rates = j['rates']! as Map<String, Object?>;
      return FxRates({
        Currency.ngn: Decimal.one,
        for (final e in rates.entries)
          if (_fiat(e.key) case final c?) c: Decimal.parse((e.value! as Map<String, Object?>)['perNgn']! as String),
      });
    });
    return switch (r) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  @override
  Future<Result<FundingAccount>> fundingAccount(Currency currency) async => mapJson(
    await _api.get('funding-accounts/${currency.code}'),
    (j) => FundingAccount(
      accountName: j['accountName']! as String,
      accountNumber: j['accountNumber']! as String,
      bankName: j['bankName']! as String,
    ),
  );

  @override
  Future<Result<ConvertQuote>> quoteConvert(Money from, Currency to) async => mapJson(
    await _api.send(
      'POST',
      'convert/quotes',
      body: {
        'from': {'amount': from.amount.toString(), 'currency': from.currency.code},
        'to': to.code,
      },
    ),
    (j) => ConvertQuote(
      id: j['id']! as String,
      from: _money(j['from']),
      receive: _money(j['receive']),
      fee: _money(j['fee']),
      rate: Decimal.parse(j['rate']! as String),
      expiresAt: DateTime.parse(j['expiresAt']! as String),
    ),
  );

  @override
  Future<Result<Transaction>> convert(ConvertQuote quote, {required String pinToken}) async => mapJson(
    await _api.send('POST', 'convert', body: {'quoteId': quote.id}, headers: {'x-pin-token': pinToken}),
    (j) => Transaction(
      id: j['receiptId']! as String,
      category: TxCategory.transfers,
      kind: TxKind.conversion,
      title: '${quote.from.currency.code} → ${quote.receive.currency.code}',
      subtitle: '',
      amount: Money(-quote.from.amount, quote.from.currency),
      createdAt: _now(),
    ),
  );

  @override
  Stream<List<PaymentRequest>> watchRequests() => _pending.watchRequests();

  @override
  Future<Result<void>> declineRequest(String id) => _pending.declineRequest(id);

  @override
  Future<Result<Transaction>> payRequest(String id, {required String pinToken}) =>
      _pending.payRequest(id, pinToken: pinToken);

  /// Test builds: the server's sandbox provider "receives" the money and
  /// credits it through the real webhook path (absent in production).
  @override
  Future<Result<Transaction>> simulateDeposit(Money amount) async => mapJson(
    await _api.send(
      'POST',
      'dev/sandbox/deposits',
      body: {'asset': amount.currency.code, 'amount': amount.amount.toString()},
    ),
    (j) => Transaction(
      id: j['reference']! as String,
      category: TxCategory.transfers,
      kind: TxKind.deposit,
      title: 'Deposit · Bank transfer',
      subtitle: '',
      amount: amount,
      createdAt: _now(),
      status: TxStatus.pending,
    ),
  );

  static Currency? _fiat(String code) => Currency.fiats.where((c) => c.code == code).firstOrNull;

  static Money _money(Object? raw) {
    final m = raw! as Map<String, Object?>;
    return Money.parse(m['amount']! as String, Currency.fromCode(m['currency']! as String));
  }
}
