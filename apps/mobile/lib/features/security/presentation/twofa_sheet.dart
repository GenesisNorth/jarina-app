import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Asks for the authenticator code; returns a 2FA token or null if cancelled.
/// Used after the PIN for withdrawals and cash-outs.
Future<String?> confirmWith2fa(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const _TwofaSheet(),
);

/// PIN then 2FA. Returns both tokens, or null if the user backs out of either.
Future<(String, String)?> confirmWithPinAnd2fa(
  BuildContext context,
  Future<String?> Function() pin,
) async {
  final p = await pin();
  if (p == null || !context.mounted) return null;
  final t = await confirmWith2fa(context);
  return t == null ? null : (p, t);
}

class _TwofaSheet extends ConsumerStatefulWidget {
  const _TwofaSheet();

  @override
  ConsumerState<_TwofaSheet> createState() => _TwofaSheetState();
}

class _TwofaSheetState extends ConsumerState<_TwofaSheet> {
  String _code = '';
  String? _error;
  bool _busy = false;
  int _shake = 0;

  Future<void> _digit(String d) async {
    if (_busy || _code.length >= 6) return;
    setState(() {
      _code += d;
      _error = null;
    });
    if (_code.length < 6) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(securityRepositoryProvider).verify2fa(_code);
    if (!mounted) return;
    r.when(
      ok: (token) => Navigator.of(context).pop(token),
      err: (f) {
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _busy = false;
          _code = '';
          _shake++;
          _error = l.failure(f);
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
                Text(l.twoFactorAuthentication, textAlign: TextAlign.center, style: t.h2),
                const SizedBox(height: 4),
                Text(
                  l.openYourAuthenticatorAppAndEnter,
                  textAlign: TextAlign.center,
                  style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 18),
                Shake(
                  trigger: _shake,
                  child: JCodeBoxes(value: _code, error: _error != null),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: _busy
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_error ?? '', style: t.caption.copyWith(color: c.down)),
                ),
                if (ref.watch(envProvider).useFakeData)
                  Text(l.demoCodeHint(FakeBackend.demoCode), style: t.caption.copyWith(color: c.muted)),
              ],
            ),
          ),
          JKeypad(
            enabled: !_busy,
            onDigit: (d) => unawaited(_digit(d)),
            onBackspace: () => setState(() => _code = _code.isEmpty ? '' : _code.substring(0, _code.length - 1)),
            onClear: () => setState(() => _code = ''),
            backspaceLabel: l.back,
          ),
        ],
      ),
    );
  }
}
