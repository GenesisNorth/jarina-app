// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cryptoTransfers)
final cryptoTransfersProvider = CryptoTransfersProvider._();

final class CryptoTransfersProvider
    extends $FunctionalProvider<AsyncValue<List<CryptoTransfer>>, List<CryptoTransfer>, Stream<List<CryptoTransfer>>>
    with $FutureModifier<List<CryptoTransfer>>, $StreamProvider<List<CryptoTransfer>> {
  CryptoTransfersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cryptoTransfersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cryptoTransfersHash();

  @$internal
  @override
  $StreamProviderElement<List<CryptoTransfer>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CryptoTransfer>> create(Ref ref) {
    return cryptoTransfers(ref);
  }
}

String _$cryptoTransfersHash() => r'c2a37c342eb7f860f796deb1bb1b02ae1db2ac98';

@ProviderFor(cryptoOrders)
final cryptoOrdersProvider = CryptoOrdersProvider._();

final class CryptoOrdersProvider
    extends $FunctionalProvider<AsyncValue<List<LimitOrder>>, List<LimitOrder>, Stream<List<LimitOrder>>>
    with $FutureModifier<List<LimitOrder>>, $StreamProvider<List<LimitOrder>> {
  CryptoOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cryptoOrdersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cryptoOrdersHash();

  @$internal
  @override
  $StreamProviderElement<List<LimitOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LimitOrder>> create(Ref ref) {
    return cryptoOrders(ref);
  }
}

String _$cryptoOrdersHash() => r'0d5a99c2f4a8fbd4375e2d411aaaca7b53332fb3';

@ProviderFor(autoSwapTarget)
final autoSwapTargetProvider = AutoSwapTargetProvider._();

final class AutoSwapTargetProvider extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  AutoSwapTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoSwapTargetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoSwapTargetHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return autoSwapTarget(ref);
  }
}

String _$autoSwapTargetHash() => r'dfeb80955f44e4171ecd8124c3026bfb9d80271b';

@ProviderFor(coinNetworks)
final coinNetworksProvider = CoinNetworksFamily._();

final class CoinNetworksProvider
    extends $FunctionalProvider<AsyncValue<List<CryptoNetwork>>, List<CryptoNetwork>, FutureOr<List<CryptoNetwork>>>
    with $FutureModifier<List<CryptoNetwork>>, $FutureProvider<List<CryptoNetwork>> {
  CoinNetworksProvider._({
    required CoinNetworksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coinNetworksProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coinNetworksHash();

  @override
  String toString() {
    return r'coinNetworksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CryptoNetwork>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CryptoNetwork>> create(Ref ref) {
    final argument = this.argument as String;
    return coinNetworks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CoinNetworksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coinNetworksHash() => r'e20b4d431122cc30496130787cb890e88b558678';

final class CoinNetworksFamily extends $Family with $FunctionalFamilyOverride<FutureOr<List<CryptoNetwork>>, String> {
  CoinNetworksFamily._()
    : super(
        retry: null,
        name: r'coinNetworksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  CoinNetworksProvider call(String coin) => CoinNetworksProvider._(argument: coin, from: this);

  @override
  String toString() => r'coinNetworksProvider';
}

/// When the user last opened Notifications; newer items count as unread.

@ProviderFor(NotificationsReadAt)
final notificationsReadAtProvider = NotificationsReadAtProvider._();

/// When the user last opened Notifications; newer items count as unread.
final class NotificationsReadAtProvider extends $NotifierProvider<NotificationsReadAt, DateTime?> {
  /// When the user last opened Notifications; newer items count as unread.
  NotificationsReadAtProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsReadAtProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsReadAtHash();

  @$internal
  @override
  NotificationsReadAt create() => NotificationsReadAt();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$notificationsReadAtHash() => r'2d128abcf7d471de7a780f3f31172f5bd347c55e';

/// When the user last opened Notifications; newer items count as unread.

abstract class _$NotificationsReadAt extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<DateTime?, DateTime?>, DateTime?, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
