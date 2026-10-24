// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalog)
final catalogProvider = CatalogProvider._();

final class CatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, AssetInfo>>,
          Map<String, AssetInfo>,
          FutureOr<Map<String, AssetInfo>>
        >
    with $FutureModifier<Map<String, AssetInfo>>, $FutureProvider<Map<String, AssetInfo>> {
  CatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, AssetInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, AssetInfo>> create(Ref ref) {
    return catalog(ref);
  }
}

String _$catalogHash() => r'33e10a592f0bcfe4672c3cbb2ceec143ed79ef60';

/// Live quotes. Not kept alive: the feed stops when no screen shows prices.

@ProviderFor(quotes)
final quotesProvider = QuotesProvider._();

/// Live quotes. Not kept alive: the feed stops when no screen shows prices.

final class QuotesProvider
    extends $FunctionalProvider<AsyncValue<Map<String, Quote>>, Map<String, Quote>, Stream<Map<String, Quote>>>
    with $FutureModifier<Map<String, Quote>>, $StreamProvider<Map<String, Quote>> {
  /// Live quotes. Not kept alive: the feed stops when no screen shows prices.
  QuotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, Quote>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, Quote>> create(Ref ref) {
    return quotes(ref);
  }
}

String _$quotesHash() => r'4fdadd98102695bdf23686ee7dbf1f0cc2901f2a';

@ProviderFor(balances)
final balancesProvider = BalancesProvider._();

final class BalancesProvider extends $FunctionalProvider<AsyncValue<Balances>, Balances, Stream<Balances>>
    with $FutureModifier<Balances>, $StreamProvider<Balances> {
  BalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balancesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balancesHash();

  @$internal
  @override
  $StreamProviderElement<Balances> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<Balances> create(Ref ref) {
    return balances(ref);
  }
}

String _$balancesHash() => r'f47236645bf4a641a2ed9a7bb033fdd3a363e4fe';

@ProviderFor(fxRates)
final fxRatesProvider = FxRatesProvider._();

final class FxRatesProvider extends $FunctionalProvider<AsyncValue<FxRates>, FxRates, FutureOr<FxRates>>
    with $FutureModifier<FxRates>, $FutureProvider<FxRates> {
  FxRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fxRatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fxRatesHash();

  @$internal
  @override
  $FutureProviderElement<FxRates> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<FxRates> create(Ref ref) {
    return fxRates(ref);
  }
}

String _$fxRatesHash() => r'99b45aecc1e3bc399002ee63d6c159d2e4cd590a';

@ProviderFor(activity)
final activityProvider = ActivityProvider._();

final class ActivityProvider
    extends $FunctionalProvider<AsyncValue<List<Transaction>>, List<Transaction>, Stream<List<Transaction>>>
    with $FutureModifier<List<Transaction>>, $StreamProvider<List<Transaction>> {
  ActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityHash();

  @$internal
  @override
  $StreamProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Transaction>> create(Ref ref) {
    return activity(ref);
  }
}

String _$activityHash() => r'b485dfc8fe6550cc529e6792d0686da3f125e5ff';

@ProviderFor(paymentRequests)
final paymentRequestsProvider = PaymentRequestsProvider._();

final class PaymentRequestsProvider
    extends $FunctionalProvider<AsyncValue<List<PaymentRequest>>, List<PaymentRequest>, Stream<List<PaymentRequest>>>
    with $FutureModifier<List<PaymentRequest>>, $StreamProvider<List<PaymentRequest>> {
  PaymentRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRequestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<PaymentRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentRequest>> create(Ref ref) {
    return paymentRequests(ref);
  }
}

String _$paymentRequestsHash() => r'ff6da8b648377bf0795003692780625b1c1268fe';

/// Combines balances × live prices × FX. Recomputes on every price tick.

@ProviderFor(portfolio)
final portfolioProvider = PortfolioProvider._();

/// Combines balances × live prices × FX. Recomputes on every price tick.

final class PortfolioProvider
    extends $FunctionalProvider<AsyncValue<Portfolio>, AsyncValue<Portfolio>, AsyncValue<Portfolio>>
    with $Provider<AsyncValue<Portfolio>> {
  /// Combines balances × live prices × FX. Recomputes on every price tick.
  PortfolioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'portfolioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$portfolioHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Portfolio>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Portfolio> create(Ref ref) {
    return portfolio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Portfolio> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Portfolio>>(value),
    );
  }
}

String _$portfolioHash() => r'7978c4b3f8c3207bb1fb3b2f485e1f219644a924';

/// Currency the user chose to see totals in (balance card switcher).

@ProviderFor(DisplayCurrency)
final displayCurrencyProvider = DisplayCurrencyProvider._();

/// Currency the user chose to see totals in (balance card switcher).
final class DisplayCurrencyProvider extends $NotifierProvider<DisplayCurrency, Currency> {
  /// Currency the user chose to see totals in (balance card switcher).
  DisplayCurrencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayCurrencyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayCurrencyHash();

  @$internal
  @override
  DisplayCurrency create() => DisplayCurrency();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Currency value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Currency>(value),
    );
  }
}

String _$displayCurrencyHash() => r'2863373117ac71f7355c7da01982ed5d8df6ee52';

/// Currency the user chose to see totals in (balance card switcher).

abstract class _$DisplayCurrency extends $Notifier<Currency> {
  Currency build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Currency, Currency>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<Currency, Currency>, Currency, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// "Hide balances" eye toggle, remembered across launches.

@ProviderFor(HideBalances)
final hideBalancesProvider = HideBalancesProvider._();

/// "Hide balances" eye toggle, remembered across launches.
final class HideBalancesProvider extends $NotifierProvider<HideBalances, bool> {
  /// "Hide balances" eye toggle, remembered across launches.
  HideBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hideBalancesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hideBalancesHash();

  @$internal
  @override
  HideBalances create() => HideBalances();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hideBalancesHash() => r'0f8bf0920506a2dafd31188069c8f9e35a27f138';

/// "Hide balances" eye toggle, remembered across launches.

abstract class _$HideBalances extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Portfolio value over [range] (week/month/year) for the balance card.
/// Cash is held flat; holdings use each asset's daily closes.

@ProviderFor(portfolioHistory)
final portfolioHistoryProvider = PortfolioHistoryFamily._();

/// Portfolio value over [range] (week/month/year) for the balance card.
/// Cash is held flat; holdings use each asset's daily closes.

final class PortfolioHistoryProvider
    extends $FunctionalProvider<AsyncValue<List<double>>, List<double>, FutureOr<List<double>>>
    with $FutureModifier<List<double>>, $FutureProvider<List<double>> {
  /// Portfolio value over [range] (week/month/year) for the balance card.
  /// Cash is held flat; holdings use each asset's daily closes.
  PortfolioHistoryProvider._({
    required PortfolioHistoryFamily super.from,
    required ChartRange super.argument,
  }) : super(
         retry: null,
         name: r'portfolioHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$portfolioHistoryHash();

  @override
  String toString() {
    return r'portfolioHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<double>> create(Ref ref) {
    final argument = this.argument as ChartRange;
    return portfolioHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PortfolioHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$portfolioHistoryHash() => r'6ccbe6581d22e0f6915a2049f4db8fe65b12a75d';

/// Portfolio value over [range] (week/month/year) for the balance card.
/// Cash is held flat; holdings use each asset's daily closes.

final class PortfolioHistoryFamily extends $Family with $FunctionalFamilyOverride<FutureOr<List<double>>, ChartRange> {
  PortfolioHistoryFamily._()
    : super(
        retry: null,
        name: r'portfolioHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Portfolio value over [range] (week/month/year) for the balance card.
  /// Cash is held flat; holdings use each asset's daily closes.

  PortfolioHistoryProvider call(ChartRange range) => PortfolioHistoryProvider._(argument: range, from: this);

  @override
  String toString() => r'portfolioHistoryProvider';
}
