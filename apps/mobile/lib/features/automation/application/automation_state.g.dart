// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(autopilotRules)
final autopilotRulesProvider = AutopilotRulesProvider._();

final class AutopilotRulesProvider
    extends $FunctionalProvider<AsyncValue<List<AutopilotRule>>, List<AutopilotRule>, Stream<List<AutopilotRule>>>
    with $FutureModifier<List<AutopilotRule>>, $StreamProvider<List<AutopilotRule>> {
  AutopilotRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autopilotRulesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autopilotRulesHash();

  @$internal
  @override
  $StreamProviderElement<List<AutopilotRule>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AutopilotRule>> create(Ref ref) {
    return autopilotRules(ref);
  }
}

String _$autopilotRulesHash() => r'129a7defb83cf2e3548b8f26cc2a319ea7a637f1';

@ProviderFor(priceAlerts)
final priceAlertsProvider = PriceAlertsProvider._();

final class PriceAlertsProvider
    extends $FunctionalProvider<AsyncValue<List<PriceAlert>>, List<PriceAlert>, Stream<List<PriceAlert>>>
    with $FutureModifier<List<PriceAlert>>, $StreamProvider<List<PriceAlert>> {
  PriceAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceAlertsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceAlertsHash();

  @$internal
  @override
  $StreamProviderElement<List<PriceAlert>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PriceAlert>> create(Ref ref) {
    return priceAlerts(ref);
  }
}

String _$priceAlertsHash() => r'091ee1aaef52945d806d456ab0174db984f9a82a';

@ProviderFor(automationEvents)
final automationEventsProvider = AutomationEventsProvider._();

final class AutomationEventsProvider
    extends $FunctionalProvider<AsyncValue<List<AutomationEvent>>, List<AutomationEvent>, Stream<List<AutomationEvent>>>
    with $FutureModifier<List<AutomationEvent>>, $StreamProvider<List<AutomationEvent>> {
  AutomationEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'automationEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$automationEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<AutomationEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AutomationEvent>> create(Ref ref) {
    return automationEvents(ref);
  }
}

String _$automationEventsHash() => r'8dc6f0fde7a6bf80ac1904f928d35f63c0d7eb27';
