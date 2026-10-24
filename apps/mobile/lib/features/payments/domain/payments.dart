import 'package:flutter/foundation.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina_core/jarina_core.dart';

enum RecipientKind {
  /// Another Jarina user: free and instant.
  jarina,

  /// A Nigerian bank account via NIP.
  bank,

  /// Mobile money or bank abroad (Niger, Ghana, Cameroon, Chad, Mali…).
  crossBorder,
}

/// Someone the user can pay. Saved recipients become beneficiaries.
@immutable
class Recipient {
  const Recipient({
    required this.id,
    required this.name,
    required this.kind,
    required this.countryIso,
    required this.currency,
    required this.avatarColor,
    this.handle,
    this.city,
    this.place,
    this.channel,
    this.bank,
    this.accountNumber,
    this.lastSent,
  });

  factory Recipient.fromSeed(Map<String, dynamic> j, {Money? lastSent}) {
    final kind = switch (j['kind']) {
      'jarina' => RecipientKind.jarina,
      'bank' => RecipientKind.bank,
      _ => RecipientKind.crossBorder,
    };
    final tag = j['tag'] as String;
    final sub = j['sub'] as String;
    final av = j['av'] as Map<String, dynamic>;
    return Recipient(
      id: j['id'] as String,
      name: j['name'] as String,
      kind: kind,
      countryIso: kind == RecipientKind.crossBorder ? _isoFrom(tag) : 'NG',
      currency: Currency.fromCode(j['cur'] as String),
      avatarColor: int.parse('FF${(av['bg'] as String).substring(1)}', radix: 16),
      handle: tag.startsWith('@') ? tag.substring(1) : null,
      city: kind == RecipientKind.crossBorder ? tag.split(',').first.trim() : null,
      place: kind == RecipientKind.crossBorder ? tag : null,
      channel: kind == RecipientKind.crossBorder ? sub.split('·').last.trim() : null,
      bank: kind == RecipientKind.bank ? 'GTBank' : null,
      accountNumber: kind == RecipientKind.bank ? '0123454821' : null,
      lastSent: lastSent,
    );
  }

  static String _isoFrom(String place) => switch (place.split(',').last.trim()) {
    'Niger' => 'NE',
    'Chad' => 'TD',
    'Cameroon' => 'CM',
    'Mali' => 'ML',
    'Ghana' => 'GH',
    'Benin' || 'Benin Republic' => 'BJ',
    'Togo' => 'TG',
    _ => 'NG',
  };

  final String id;
  final String name;
  final RecipientKind kind;
  final String countryIso;

  /// What the recipient receives (XOF for Niger, XAF for Cameroon…).
  final Currency currency;
  final int avatarColor;
  final String? handle;
  final String? city;

  /// `Maradi, Niger`.
  final String? place;

  /// `Mobile money`, `Bank`…
  final String? channel;
  final String? bank;
  final String? accountNumber;
  final Money? lastSent;

  String get firstName => name.split(' ').first;
  String get initials => name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase();
}

/// A priced send. Cross-border rates are locked for 10 minutes.
@immutable
class SendQuote {
  const SendQuote({
    required this.id,
    required this.recipient,
    required this.amount,
    required this.fee,
    required this.debit,
    required this.receive,
    required this.rate,
    required this.expiresAt,
  });

  final String id;
  final Recipient recipient;

  /// What the user sends, in NGN.
  final Money amount;
  final Money fee;

  /// What leaves the chosen wallet (NGN, or a coin when paying from crypto).
  final Money debit;

  /// What the recipient gets, in their currency.
  final Money receive;

  /// Units of the recipient's currency per 1 NGN.
  final Decimal rate;
  final DateTime expiresAt;

  bool get crossBorder => recipient.kind == RecipientKind.crossBorder;
}

/// A Jarina user found by @username.
@immutable
class JarinaUser {
  const JarinaUser({required this.name, required this.handle});

  final String name;
  final String handle;
}

abstract interface class PaymentsRepository {
  Future<List<Recipient>> recipients();

  Future<Result<JarinaUser>> lookupUser(String handle);

  Future<Result<BankAccount>> resolveBankAccount(String bank, String accountNumber);

  /// [from] is the wallet paying: `NGN` or a coin code (converted at the swap rate).
  Future<Result<SendQuote>> quoteSend(Recipient to, Money amount, {String from = 'NGN'});

  /// Cross-border sends need [twofaToken] (bank and P2P need only the PIN).
  Future<Result<Transaction>> send(SendQuote quote, {required String pinToken, String? twofaToken, String? note});

  /// Free, instant P2P of cash (NGN), a coin, or NGX shares to a @username.
  Future<Result<Transaction>> sendP2p({
    required String handle,
    required String asset,
    required Decimal amount,
    required String pinToken,
    String? note,
  });

  /// Ask a Jarina user to pay you; they get a push and see it in Receive.
  Future<Result<void>> requestMoney({required String handle, required Money amount, String? note});
}

enum BillKind { airtime, data, cable, electricity }

@immutable
class BillPlan {
  const BillPlan({required this.name, required this.price});

  final String name;
  final Money price;
}

@immutable
class Biller {
  const Biller({
    required this.kind,
    required this.providers,
    required this.plans,
    required this.quickAmounts,
    required this.min,
    required this.max,
  });

  final BillKind kind;
  final List<String> providers;

  /// Data bundles / TV packages. Empty for airtime and electricity.
  final List<BillPlan> plans;
  final List<Money> quickAmounts;
  final Money min;
  final Money max;

  /// Cable and electricity are validated against the provider first.
  bool get needsCustomerLookup => kind == BillKind.cable || kind == BillKind.electricity;
}

abstract interface class BillsRepository {
  Future<Biller> biller(BillKind kind);

  /// Name enquiry for a smartcard or meter.
  Future<Result<String>> verifyCustomer(BillKind kind, String provider, String number, {bool prepaid = true});

  /// Pays and returns the receipt. Prepaid electricity puts the token in the
  /// transaction description.
  Future<Result<Transaction>> pay({
    required BillKind kind,
    required String provider,
    required String number,
    required Money amount,
    required String pinToken,
    String? plan,
    bool prepaid = true,
  });
}
