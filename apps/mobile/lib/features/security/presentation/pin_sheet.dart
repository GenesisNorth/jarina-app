import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Asks for the transaction PIN and returns a step-up token, or null if the
/// user cancels. Every money-moving action goes through this.
Future<String?> confirmWithPin(BuildContext context, {required String action}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _PinSheet(action: action),
);

class _PinSheet extends ConsumerStatefulWidget {
  const _PinSheet({required this.action});

  final String action;

  @override
  ConsumerState<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends ConsumerState<_PinSheet> {
  String _pin = '';
  String? _error;
  bool _busy = false;
  bool _locked = false;
  int _shake = 0;

  Future<void> _digit(String d) async {
    if (_busy || _locked || _pin.length >= PinRules.length) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length < PinRules.length) return;

    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(securityRepositoryProvider).verifyPin(_pin);
    if (!mounted) return;
    r.when(
      ok: (token) => Navigator.of(context).pop(token),
      err: (f) {
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _busy = false;
          _pin = '';
          _shake++;
          _locked = f is PinLockedFailure;
          _error = switch (f) {
            WrongPinFailure(:final attemptsLeft) => l.errWrongPin('$attemptsLeft'),
            PinLockedFailure() => l.errPinLocked,
            _ => l.failure(f),
          };
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            child: Column(
              children: [
                Text(l.enterYourPin, textAlign: TextAlign.center, style: t.h2),
                const SizedBox(height: 4),
                Text(
                  l.pinToApprove(widget.action),
                  textAlign: TextAlign.center,
                  style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 22),
                Shake(
                  trigger: _shake,
                  child: JPinDots(filled: _pin.length, error: _error != null),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 20,
                  child: _busy
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Semantics(
                          liveRegion: true,
                          child: Text(_error ?? '', style: t.caption.copyWith(color: c.down)),
                        ),
                ),
              ],
            ),
          ),
          JKeypad(
            enabled: !_busy && !_locked,
            onDigit: (d) => unawaited(_digit(d)),
            onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
            onClear: () => setState(() => _pin = ''),
            backspaceLabel: l.back,
          ),
        ],
      ),
    );
  }
}
