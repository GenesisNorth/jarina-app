import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/automation/domain/automation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'automation_state.g.dart';

@Riverpod(keepAlive: true)
Stream<List<AutopilotRule>> autopilotRules(Ref ref) => ref.watch(automationRepositoryProvider).watchRules();

@Riverpod(keepAlive: true)
Stream<List<PriceAlert>> priceAlerts(Ref ref) => ref.watch(automationRepositoryProvider).watchAlerts();

@Riverpod(keepAlive: true)
Stream<List<AutomationEvent>> automationEvents(Ref ref) => ref.watch(automationRepositoryProvider).watchEvents();
