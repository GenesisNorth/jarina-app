import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/payments/domain/payments.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payments_state.g.dart';

@riverpod
Future<List<Recipient>> recipients(Ref ref) => ref.watch(paymentsRepositoryProvider).recipients();

@riverpod
Future<Biller> biller(Ref ref, BillKind kind) => ref.watch(billsRepositoryProvider).biller(kind);

/// What the Transfers keypad holds: an NGN amount and the wallet paying.
typedef TransferDraftState = ({Decimal amount, String from});

@Riverpod(keepAlive: true)
class TransferDraft extends _$TransferDraft {
  @override
  TransferDraftState build() => (amount: Decimal.zero, from: 'NGN');

  void setAmount(Decimal amount) => state = (amount: amount, from: state.from);
  void setFrom(String from) => state = (amount: state.amount, from: from);
  void reset() => state = build();
}

/// Who Pay confirm is paying (a beneficiary, a found user or a new bank account).
@Riverpod(keepAlive: true)
class SelectedRecipient extends _$SelectedRecipient {
  @override
  Recipient? build() => null;

  // ignore: use_setters_to_change_properties, same as PendingTrade.set.
  void set(Recipient r) => state = r;
}

/// A send approved on Pay confirm, handed to the Sending screen.
typedef ApprovedSend = ({SendQuote quote, String pinToken, String? twofaToken, String? note});

@Riverpod(keepAlive: true)
class PendingSend extends _$PendingSend {
  @override
  ApprovedSend? build() => null;

  // ignore: use_setters_to_change_properties, same as PendingTrade.set.
  void set(ApprovedSend? s) => state = s;
}

/// The payment just sent, for the celebration screen.
@Riverpod(keepAlive: true)
class LastPayment extends _$LastPayment {
  @override
  (SendQuote, Transaction)? build() => null;

  // ignore: use_setters_to_change_properties, same as PendingTrade.set.
  void set((SendQuote, Transaction) p) => state = p;
}

/// The P2P send or request just made, for the P2P done screen.
typedef P2pResult = ({String name, String handle, String value, bool request, Transaction? tx});

@Riverpod(keepAlive: true)
class LastP2p extends _$LastP2p {
  @override
  P2pResult? build() => null;

  // ignore: use_setters_to_change_properties, same as PendingTrade.set.
  void set(P2pResult r) => state = r;
}
