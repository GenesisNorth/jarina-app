// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trading_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Quote being reviewed (Trade → Review). Cleared once the order is placed.

@ProviderFor(PendingTrade)
final pendingTradeProvider = PendingTradeProvider._();

/// Quote being reviewed (Trade → Review). Cleared once the order is placed.
final class PendingTradeProvider extends $NotifierProvider<PendingTrade, TradeQuote?> {
  /// Quote being reviewed (Trade → Review). Cleared once the order is placed.
  PendingTradeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTradeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTradeHash();

  @$internal
  @override
  PendingTrade create() => PendingTrade();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TradeQuote? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TradeQuote?>(value),
    );
  }
}

String _$pendingTradeHash() => r'3257cfb0e3c496d60a75f582deff961803bb97ba';

/// Quote being reviewed (Trade → Review). Cleared once the order is placed.

abstract class _$PendingTrade extends $Notifier<TradeQuote?> {
  TradeQuote? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TradeQuote?, TradeQuote?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<TradeQuote?, TradeQuote?>, TradeQuote?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// The order just placed, for the confirmation screen.

@ProviderFor(LastOrder)
final lastOrderProvider = LastOrderProvider._();

/// The order just placed, for the confirmation screen.
final class LastOrderProvider extends $NotifierProvider<LastOrder, (TradeQuote, Transaction)?> {
  /// The order just placed, for the confirmation screen.
  LastOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastOrderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastOrderHash();

  @$internal
  @override
  LastOrder create() => LastOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((TradeQuote, Transaction)? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(TradeQuote, Transaction)?>(value),
    );
  }
}

String _$lastOrderHash() => r'036767eae1d635ef6f628e06c8e98266af63f259';

/// The order just placed, for the confirmation screen.

abstract class _$LastOrder extends $Notifier<(TradeQuote, Transaction)?> {
  (TradeQuote, Transaction)? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<(TradeQuote, Transaction)?, (TradeQuote, Transaction)?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<(TradeQuote, Transaction)?, (TradeQuote, Transaction)?>,
              (TradeQuote, Transaction)?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Starred assets, stored on the device.

@ProviderFor(Watchlist)
final watchlistProvider = WatchlistProvider._();

/// Starred assets, stored on the device.
final class WatchlistProvider extends $NotifierProvider<Watchlist, Set<String>> {
  /// Starred assets, stored on the device.
  WatchlistProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchlistProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchlistHash();

  @$internal
  @override
  Watchlist create() => Watchlist();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$watchlistHash() => r'0cda5e08527e900366057c89825fbbdf2c168f95';

/// Starred assets, stored on the device.

abstract class _$Watchlist extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<Set<String>, Set<String>>, Set<String>, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(assetHistory)
final assetHistoryProvider = AssetHistoryFamily._();

final class AssetHistoryProvider
    extends $FunctionalProvider<AsyncValue<List<double>>, List<double>, FutureOr<List<double>>>
    with $FutureModifier<List<double>>, $FutureProvider<List<double>> {
  AssetHistoryProvider._({
    required AssetHistoryFamily super.from,
    required (String, ChartRange) super.argument,
  }) : super(
         retry: null,
         name: r'assetHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetHistoryHash();

  @override
  String toString() {
    return r'assetHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<double>> create(Ref ref) {
    final argument = this.argument as (String, ChartRange);
    return assetHistory(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AssetHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetHistoryHash() => r'6410933f8b16818e62907d586e4f6c091688fdfb';

final class AssetHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<double>>, (String, ChartRange)> {
  AssetHistoryFamily._()
    : super(
        retry: null,
        name: r'assetHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AssetHistoryProvider call(String assetId, ChartRange range) =>
      AssetHistoryProvider._(argument: (assetId, range), from: this);

  @override
  String toString() => r'assetHistoryProvider';
}
