import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Steps 10–11 · Create and confirm the 6-digit transaction PIN.
///
/// The PIN only lives in this widget's memory, is sent once to the server
/// (which stores a salted hash) and is never written to disk.
class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _first = '';
  String _entry = '';
  bool _confirming = false;
  bool _busy = false;
  String? _error;
  int _shake = 0;

  void _fail(String message, {bool restart = false}) {
    unawaited(HapticFeedback.heavyImpact());
    setState(() {
      _error = message;
      _entry = '';
      _shake++;
      if (restart) {
        _confirming = false;
        _first = '';
      }
    });
  }

  Future<void> _digit(String d) async {
    if (_busy || _entry.length >= PinRules.length) return;
    setState(() {
      _entry += d;
      _error = null;
    });
    if (_entry.length < PinRules.length) return;

    final l = AppLocalizations.of(context);
    // Let the last dot fill before reacting.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (!_confirming) {
      final err = PinRules.validate(_entry);
      if (err != null) return _fail(l.field(err));
      setState(() {
        _first = _entry;
        _entry = '';
        _confirming = true;
      });
      return;
    }

    if (_entry != _first) return _fail(l.errPinMismatch, restart: true);

    setState(() => _busy = true);
    final r = await ref.read(kycRepositoryProvider).setPin(_first);
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) async {
        _first = '';
        _entry = '';
        await advanceKyc(context, ref, AppRoute.kyc6);
      },
      err: (f) async => _fail(l.failure(f), restart: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final step = _confirming ? 11 : 10;

    Widget stageChip(String label, {required bool on}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: on ? c.black : c.fill, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: t.caption.copyWith(fontWeight: FontWeight.w600, color: on ? Colors.white : c.muted),
      ),
    );

    return JFlowScaffold(
      onBack: () => _confirming
          ? setState(() {
              _confirming = false;
              _first = '';
              _entry = '';
            })
          : context.go(AppRoute.kyc4.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottomPadded: false,
      bottom: JKeypad(
        enabled: !_busy,
        onDigit: (d) => unawaited(_digit(d)),
        onBackspace: () => setState(() => _entry = _entry.isEmpty ? '' : _entry.substring(0, _entry.length - 1)),
        onClear: () => setState(() => _entry = ''),
        backspaceLabel: l.back,
      ),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, step, l.verification),
          progress: step / onboardingSteps,
          title: _confirming ? l.confirmYourPin : l.createATransactionPin,
          subtitle: l.youLlUseThis6Digit,
        ),
        const SizedBox(height: 12),
        kycTracker(l, step),
        const SizedBox(height: 18),
        JCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Column(
            children: [
              Shake(
                trigger: _shake,
                child: JPinDots(filled: _entry.length, error: _error != null),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  stageChip(l.pinCreateStep, on: !_confirming),
                  stageChip(l.pinConfirmStep, on: _confirming),
                ],
              ),
              const SizedBox(height: 14),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error ?? l.avoidBirthdaysAndRepeatedDigitsLike,
                  textAlign: TextAlign.center,
                  style: t.caption.copyWith(color: _error != null ? c.down : c.muted, height: 1.4),
                ),
              ),
              if (_busy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
            ],
          ),
        ),
      ],
    );
  }
}
