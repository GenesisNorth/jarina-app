// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recipients)
final recipientsProvider = RecipientsProvider._();

final class RecipientsProvider
    extends $FunctionalProvider<AsyncValue<List<Recipient>>, List<Recipient>, FutureOr<List<Recipient>>>
    with $FutureModifier<List<Recipient>>, $FutureProvider<List<Recipient>> {
  RecipientsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recipientsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recipientsHash();

  @$internal
  @override
  $FutureProviderElement<List<Recipient>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recipient>> create(Ref ref) {
    return recipients(ref);
  }
}

String _$recipientsHash() => r'c831a0c270bf89c6432406d8a79e53553c30924b';

@ProviderFor(biller)
final billerProvider = BillerFamily._();

final class BillerProvider extends $FunctionalProvider<AsyncValue<Biller>, Biller, FutureOr<Biller>>
    with $FutureModifier<Biller>, $FutureProvider<Biller> {
  BillerProvider._({
    required BillerFamily super.from,
    required BillKind super.argument,
  }) : super(
         retry: null,
         name: r'billerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$billerHash();

  @override
  String toString() {
    return r'billerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Biller> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Biller> create(Ref ref) {
    final argument = this.argument as BillKind;
    return biller(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BillerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$billerHash() => r'bfe6c9a514a42ca279a80bf815da8c96e29f7926';

final class BillerFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Biller>, BillKind> {
  BillerFamily._()
    : super(
        retry: null,
        name: r'billerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BillerProvider call(BillKind kind) => BillerProvider._(argument: kind, from: this);

  @override
  String toString() => r'billerProvider';
}

@ProviderFor(TransferDraft)
final transferDraftProvider = TransferDraftProvider._();

final class TransferDraftProvider extends $NotifierProvider<TransferDraft, TransferDraftState> {
  TransferDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferDraftHash();

  @$internal
  @override
  TransferDraft create() => TransferDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferDraftState>(value),
    );
  }
}

String _$transferDraftHash() => r'd0b87f41b0ec474b4f09553bc3e3a01eb1229348';

abstract class _$TransferDraft extends $Notifier<TransferDraftState> {
  TransferDraftState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransferDraftState, TransferDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransferDraftState, TransferDraftState>,
              TransferDraftState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Who Pay confirm is paying (a beneficiary, a found user or a new bank account).

@ProviderFor(SelectedRecipient)
final selectedRecipientProvider = SelectedRecipientProvider._();

/// Who Pay confirm is paying (a beneficiary, a found user or a new bank account).
final class SelectedRecipientProvider extends $NotifierProvider<SelectedRecipient, Recipient?> {
  /// Who Pay confirm is paying (a beneficiary, a found user or a new bank account).
  SelectedRecipientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRecipientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRecipientHash();

  @$internal
  @override
  SelectedRecipient create() => SelectedRecipient();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Recipient? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Recipient?>(value),
    );
  }
}

String _$selectedRecipientHash() => r'ac11db9a7eec0928a190f18a1bbd22900eca2416';

/// Who Pay confirm is paying (a beneficiary, a found user or a new bank account).

abstract class _$SelectedRecipient extends $Notifier<Recipient?> {
  Recipient? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Recipient?, Recipient?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<Recipient?, Recipient?>, Recipient?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(PendingSend)
final pendingSendProvider = PendingSendProvider._();

final class PendingSendProvider extends $NotifierProvider<PendingSend, ApprovedSend?> {
  PendingSendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSendHash();

  @$internal
  @override
  PendingSend create() => PendingSend();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ApprovedSend? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ApprovedSend?>(value),
    );
  }
}

String _$pendingSendHash() => r'231455b5c142cae054930df38cd7b33854a59b23';

abstract class _$PendingSend extends $Notifier<ApprovedSend?> {
  ApprovedSend? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ApprovedSend?, ApprovedSend?>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<ApprovedSend?, ApprovedSend?>, ApprovedSend?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// The payment just sent, for the celebration screen.

@ProviderFor(LastPayment)
final lastPaymentProvider = LastPaymentProvider._();

/// The payment just sent, for the celebration screen.
final class LastPaymentProvider extends $NotifierProvider<LastPayment, (SendQuote, Transaction)?> {
  /// The payment just sent, for the celebration screen.
  LastPaymentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastPaymentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastPaymentHash();

  @$internal
  @override
  LastPayment create() => LastPayment();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((SendQuote, Transaction)? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(SendQuote, Transaction)?>(value),
    );
  }
}

String _$lastPaymentHash() => r'cb6f840d3f4b82ef6d9ed81cb7a127c37a16870d';

/// The payment just sent, for the celebration screen.

abstract class _$LastPayment extends $Notifier<(SendQuote, Transaction)?> {
  (SendQuote, Transaction)? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<(SendQuote, Transaction)?, (SendQuote, Transaction)?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<(SendQuote, Transaction)?, (SendQuote, Transaction)?>,
              (SendQuote, Transaction)?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LastP2p)
final lastP2pProvider = LastP2pProvider._();

final class LastP2pProvider extends $NotifierProvider<LastP2p, P2pResult?> {
  LastP2pProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastP2pProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastP2pHash();

  @$internal
  @override
  LastP2p create() => LastP2p();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(P2pResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<P2pResult?>(value),
    );
  }
}

String _$lastP2pHash() => r'90755db3a8e91708abb3c4230941ebbbe48766ce';

abstract class _$LastP2p extends $Notifier<P2pResult?> {
  P2pResult? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<P2pResult?, P2pResult?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<P2pResult?, P2pResult?>, P2pResult?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
