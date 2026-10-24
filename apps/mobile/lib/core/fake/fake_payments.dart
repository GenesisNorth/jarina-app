import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:jarina/core/fake/fake_directory.dart';
import 'package:jarina/core/fake/fake_ledger.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina_core/jarina_core.dart';

/// Transfers, P2P and bills against the fake ledger's balances.
class FakePayments implements PaymentsRepository, BillsRepository {
  FakePayments(this._ledger, {AssetBundle? bundle, this.latency = const Duration(milliseconds: 350)})
    : _bundle = bundle ?? rootBundle;

  final FakeLedger _ledger;
  final AssetBundle _bundle;
  final Duration latency;
  final _random = Random(11);

  static final Money nipFee = Money.parse('25', Currency.ngn);
  static final Money crossBorderFee = Money.parse('300', Currency.ngn);

  /// Per-transaction ceiling for a Tier 2 account (sample; set by the regulator per tier).
  static final Money sendLimit = Money.parse('5000000', Currency.ngn);

  Future<void> _wait() async {
    await _ledger.ready;
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  List<Recipient>? _recipients;

  @override
  Future<List<Recipient>> recipients() async {
    await _ledger.ready;
    if (_recipients != null) return _recipients!;
    final raw = jsonDecode(await _bundle.loadString('assets/seed/recipients.json')) as List;
    const last = {'r5': '3000', 'r1': '50000', 'r3': '20000', 'r6': '1500', 'r2': '35000'};
    return _recipients = [
      for (final r in raw.cast<Map<String, dynamic>>())
        Recipient.fromSeed(
          r,
          lastSent: last[r['id']] == null ? null : Money.parse(last[r['id']]!, Currency.ngn),
        ),
    ];
  }

  @override
  Future<Result<JarinaUser>> lookupUser(String handle) async {
    await _wait();
    final h = UsernameRules.normalize(handle);
    final name = fakeUsers[h];
    return name == null ? const Err(UserNotFoundFailure()) : Ok(JarinaUser(name: name, handle: h));
  }

  @override
  Future<Result<BankAccount>> resolveBankAccount(String bank, String accountNumber) => _ledger
      .resolveAccount(bank, accountNumber)
      .then(
        (r) => r.map((a) => BankAccount(bank: bank, number: accountNumber, name: 'IBRAHIM MUSA')),
      );

  @override
  Future<Result<SendQuote>> quoteSend(Recipient to, Money amount, {String from = 'NGN'}) async {
    await _wait();
    if (!amount.isPositive) return const Err(ValidationFailure('Enter an amount'));
    if (to.kind != RecipientKind.jarina && amount > sendLimit) {
      return Err(LimitExceededFailure('Above ${MoneyFormat.format(sendLimit)} per transfer'));
    }
    final fee = switch (to.kind) {
      RecipientKind.jarina => Money.zero(Currency.ngn),
      RecipientKind.bank => nipFee,
      RecipientKind.crossBorder => crossBorderFee,
    };
    final totalNgn = amount + fee;
    final Money debit;
    if (from == 'NGN') {
      debit = totalNgn;
    } else {
      // Paying from crypto sells just enough at the swap rate (incl. trade fee), rounded up.
      final unit = _ledger.unitOf(from);
      final needed = (totalNgn.amount * (Decimal.one + _ledger.feeRate) / _ledger.priceOf(from)).toDecimal(
        scaleOnInfinitePrecision: 12,
      );
      debit = Money(needed.ceil(scale: unit.decimals), unit);
    }
    if (debit > _ledger.availableOf(from)) return const Err(InsufficientFundsFailure());
    final rate = _ledger.fx.perNgn[to.currency] ?? Decimal.one;
    return Ok(
      SendQuote(
        id: _ledger.newTxId(),
        recipient: to,
        amount: amount,
        fee: fee,
        debit: debit,
        receive: _ledger.fx.convert(amount, to.currency),
        rate: rate,
        expiresAt: _ledger.now().add(const Duration(minutes: 10)),
      ),
    );
  }

  @override
  Future<Result<Transaction>> send(SendQuote q, {required String pinToken, String? twofaToken, String? note}) async {
    await _wait();
    if (_ledger.now().isAfter(q.expiresAt)) return const Err(QuoteExpiredFailure());
    if (q.crossBorder && twofaToken == null) return const Err(StepUpRequiredFailure(StepUpLevel.pinAnd2fa));
    if (q.debit > _ledger.availableOf(q.debit.currency.code)) return const Err(InsufficientFundsFailure());
    _ledger.adjust(q.debit.currency.code, -q.debit.amount);
    final r = q.recipient;
    final t = Transaction(
      id: _ledger.newTxId(),
      category: TxCategory.transfers,
      kind: switch (r.kind) {
        RecipientKind.jarina => TxKind.p2p,
        RecipientKind.bank => TxKind.bankTransfer,
        RecipientKind.crossBorder => TxKind.crossBorder,
      },
      title: 'Sent to ${r.name}',
      subtitle: switch (r.kind) {
        RecipientKind.jarina => '@${r.handle}',
        RecipientKind.bank => '${r.bank} ••${r.accountNumber?.substring(6)}',
        RecipientKind.crossBorder => '${r.city} · ${r.currency.code}',
      },
      amount: -(q.amount + q.fee),
      createdAt: _ledger.now(),
      // Cross-border payouts settle in minutes; P2P and NIP are immediate.
      status: q.crossBorder ? TxStatus.pending : TxStatus.successful,
      counterparty: '${r.name} · ${r.channel ?? r.bank ?? 'Jarina'}',
      corridor: q.crossBorder ? ('NG', r.countryIso) : null,
      description: [
        if (note != null && note.isNotEmpty) note,
        if (q.crossBorder)
          'They get ${MoneyFormat.format(q.receive)} · 1 NGN = ${q.rate.round(scale: 4)} ${r.currency.code}',
        if (q.fee.isPositive) 'Fee ${MoneyFormat.format(q.fee)}',
        if (q.debit.currency != Currency.ngn) 'Paid with ${MoneyFormat.format(q.debit)}',
      ].join(' · '),
    );
    _ledger.record(t);
    return Ok(t);
  }

  @override
  Future<Result<Transaction>> sendP2p({
    required String handle,
    required String asset,
    required Decimal amount,
    required String pinToken,
    String? note,
  }) async {
    await _wait();
    final h = UsernameRules.normalize(handle);
    final name = fakeUsers[h];
    if (name == null) return const Err(UserNotFoundFailure());
    if (h == 'aminu') return const Err(ValidationFailure('You cannot send to yourself'));
    if (amount <= Decimal.zero) return const Err(ValidationFailure('Enter an amount'));
    final isStock = await _isStock(asset);
    if (isStock && amount != amount.floor()) return const Err(ValidationFailure('Whole shares only'));
    final unit = isStock ? Currency.crypto(asset, decimals: 0) : _ledger.unitOf(asset);
    if (amount > _ledger.availableOf(asset).amount) return const Err(InsufficientFundsFailure());
    _ledger.adjust(asset, -amount);
    final value = isStock ? '$amount shares of $asset' : MoneyFormat.format(Money(amount, unit));
    final t = Transaction(
      id: _ledger.newTxId(),
      category: isStock ? TxCategory.stocks : (asset == 'NGN' ? TxCategory.transfers : TxCategory.crypto),
      kind: TxKind.p2p,
      title: 'Sent to $name',
      subtitle: '@$h · $value',
      amount: asset == 'NGN'
          ? -Money(amount, Currency.ngn)
          : -Money(amount * _ledger.priceOf(asset), Currency.ngn).rounded(),
      createdAt: _ledger.now(),
      counterparty: '$name · @$h',
      description: [value, ?note, 'Free · instant'].join(' · '),
    );
    _ledger.record(t);
    return Ok(t);
  }

  Future<bool> _isStock(String id) async => (await _ledger.catalog()).any((a) => a.id == id && a.isStock);

  @override
  Future<Result<void>> requestMoney({required String handle, required Money amount, String? note}) async {
    await _wait();
    final h = UsernameRules.normalize(handle);
    if (!fakeUsers.containsKey(h)) return const Err(UserNotFoundFailure());
    if (!amount.isPositive) return const Err(ValidationFailure('Enter an amount'));
    return const Ok(null);
  }

  // ── Bills ───────────────────────────────────────────────────────────────

  Map<String, dynamic>? _bills;

  @override
  Future<Biller> biller(BillKind kind) async {
    await _ledger.ready;
    _bills ??= jsonDecode(await _bundle.loadString('assets/seed/bills.json')) as Map<String, dynamic>;
    final b = _bills![kind.name] as Map<String, dynamic>;
    Money ngn(num v) => Money.parse('$v', Currency.ngn);
    return Biller(
      kind: kind,
      providers: (b['providers'] as List).cast<String>(),
      plans: [
        for (final p in (b['plans'] as List? ?? const []))
          BillPlan(name: (p as List)[0] as String, price: ngn(p[1] as num)),
      ],
      quickAmounts: [for (final a in (b['amounts'] as List? ?? const [])) ngn(a as num)],
      min: ngn(kind == BillKind.electricity ? 1000 : 50),
      max: ngn(kind == BillKind.electricity ? 200000 : 50000),
    );
  }

  @override
  Future<Result<String>> verifyCustomer(BillKind kind, String provider, String number, {bool prepaid = true}) async {
    await _wait();
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final ok = switch (kind) {
      BillKind.cable => digits.length == 10,
      BillKind.electricity => digits.length == 11 || digits.length == 13,
      _ => digits.length == 11,
    };
    if (!ok || RegExp(r'^0+$').hasMatch(digits)) return const Err(ValidationFailure('Customer not found'));
    return Ok(kind == BillKind.electricity ? 'AMINU BELLO · ${prepaid ? 'Prepaid' : 'Postpaid'}' : 'AMINU BELLO');
  }

  @override
  Future<Result<Transaction>> pay({
    required BillKind kind,
    required String provider,
    required String number,
    required Money amount,
    required String pinToken,
    String? plan,
    bool prepaid = true,
  }) async {
    await _wait();
    final b = await biller(kind);
    if (plan == null && (amount < b.min || amount > b.max)) {
      return Err(ValidationFailure('Between ${MoneyFormat.format(b.min)} and ${MoneyFormat.format(b.max)}'));
    }
    if (amount > _ledger.availableOf('NGN')) return const Err(InsufficientFundsFailure());
    _ledger.adjust('NGN', -amount.amount);
    final token = kind == BillKind.electricity && prepaid
        ? List.generate(5, (_) => (1000 + _random.nextInt(9000)).toString()).join('-')
        : null;
    final label = switch (kind) {
      BillKind.airtime => 'Airtime',
      BillKind.data => 'Data',
      BillKind.cable => 'Cable TV',
      BillKind.electricity => 'Electricity',
    };
    final t = Transaction(
      id: _ledger.newTxId(),
      category: TxCategory.bills,
      kind: TxKind.bill,
      title: '$label · $provider',
      subtitle: plan ?? (kind == BillKind.electricity ? (prepaid ? 'Prepaid token' : 'Postpaid') : number),
      amount: -amount,
      createdAt: _ledger.now(),
      counterparty: '$provider · $number',
      description: token == null ? (plan ?? number) : 'Token $token',
    );
    _ledger.record(t);
    return Ok(t);
  }
}
