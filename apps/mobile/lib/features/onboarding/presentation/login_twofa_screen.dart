import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/fake/fake_backend.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// 2FA code at login on a new device (authenticator or backup code).
class LoginTwofaScreen extends ConsumerStatefulWidget {
  const LoginTwofaScreen({super.key});

  @override
  ConsumerState<LoginTwofaScreen> createState() => _LoginTwofaScreenState();
}

class _LoginTwofaScreenState extends ConsumerState<LoginTwofaScreen> {
  String _code = '';
  final _backup = TextEditingController();
  bool _useBackup = false;
  bool _busy = false;
  String? _error;
  int _shake = 0;

  @override
  void dispose() {
    _backup.dispose();
    super.dispose();
  }

  Future<void> _submit(String code) async {
    final ticket = ref.read(onboardingProvider).loginTicket;
    if (ticket == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref
        .read(authRepositoryProvider)
        .completeLogin(ticket: ticket, code: code, isBackupCode: _useBackup);
    if (!mounted) return;
    await r.when(
      ok: (session) => ref.read(sessionProvider.notifier).signIn(session),
      err: (f) async {
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _busy = false;
          _code = '';
          _error = l.failure(f);
          _shake++;
        });
      },
    );
  }

  void _digit(String d) {
    if (_busy || _code.length >= 6) return;
    setState(() {
      _code += d;
      _error = null;
    });
    if (_code.length == 6) unawaited(_submit(_code));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    if (ref.watch(onboardingProvider.select((s) => s.loginTicket)) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('${AppRoute.phone.path}?mode=login');
      });
      return const SizedBox.shrink();
    }

    return JFlowScaffold(
      onBack: () => context.go('${AppRoute.phone.path}?mode=login'),
      backLabel: l.back,
      bottomPadded: _useBackup,
      bottom: _useBackup
          ? JButton(label: l.continueLabel, loading: _busy, onPressed: () => _submit(_backup.text.replaceAll(' ', '')))
          : JKeypad(
              enabled: !_busy,
              onDigit: _digit,
              onBackspace: () => setState(() => _code = _code.isEmpty ? '' : _code.substring(0, _code.length - 1)),
              onClear: () => setState(() => _code = ''),
              backspaceLabel: l.back,
            ),
      children: [
        JStepHeader(title: l.twoFactorAuthentication, subtitle: l.openYourAuthenticatorAppAndEnter),
        const SizedBox(height: 24),
        if (_useBackup)
          JTextField(
            label: l.backupCodeHint,
            controller: _backup,
            hint: 'ABCD EFGH',
            errorText: _error,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            maxLength: 9,
            onSubmitted: (v) => _submit(v.replaceAll(' ', '')),
          )
        else ...[
          Shake(
            trigger: _shake,
            child: Row(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 36,
                          child: Center(
                            child: Text(i < _code.length ? _code[i] : '', style: t.title.copyWith(fontSize: 26)),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          height: 3,
                          decoration: BoxDecoration(
                            color: _error != null ? c.down : (i <= _code.length ? c.gold : c.line),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: t.caption.copyWith(color: c.down)),
          ],
          if (_busy) ...[const SizedBox(height: 12), const LinearProgressIndicator()],
        ],
        const SizedBox(height: 20),
        JCallout(text: l.newDeviceDetectedThisLoginIs),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() {
              _useBackup = !_useBackup;
              _error = null;
              _code = '';
            }),
            child: Text(
              _useBackup ? l.useAuthenticatorInstead : l.useABackupCodeInstead,
              style: t.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (ref.watch(envProvider).useFakeData && !_useBackup)
          Text(l.demoCodeHint(FakeBackend.demoCode), style: t.caption.copyWith(color: c.muted)),
      ],
    );
  }
}
