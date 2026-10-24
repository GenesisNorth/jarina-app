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
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 4 · Verify your WhatsApp number (6 digits, SMS fallback).
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';
  String? _error;
  bool _busy = false;
  int _shake = 0;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _digit(String d) {
    if (_busy || _code.length >= 6) return;
    setState(() {
      _code += d;
      _error = null;
    });
    if (_code.length == 6) unawaited(_verify());
  }

  Future<void> _verify() async {
    final challenge = ref.read(onboardingProvider).challenge;
    if (challenge == null) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(authRepositoryProvider).verifyOtp(challengeId: challenge.id, code: _code);
    if (!mounted) return;
    await r.when(
      ok: (outcome) async {
        switch (outcome) {
          case SignedIn(:final session):
            final notifier = ref.read(sessionProvider.notifier);
            if (!session.onboarded) await notifier.setKycStep(AppRoute.kyc1.name);
            await notifier.signIn(session);
          // The router guard moves the user on (KYC or Home).
          case TwofaRequired(:final ticket):
            ref.read(onboardingProvider.notifier).setLoginTicket(ticket);
            if (mounted) context.go(AppRoute.twofa.path);
        }
      },
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

  Future<void> _resend(OtpChannel channel) async {
    final challenge = ref.read(onboardingProvider).challenge;
    if (challenge == null) return;
    final l = AppLocalizations.of(context);
    final r = await ref
        .read(authRepositoryProvider)
        .sendOtp(phoneE164: challenge.phoneE164, channel: channel, purpose: challenge.purpose);
    if (!mounted) return;
    r.when(
      ok: (c) {
        ref.read(onboardingProvider.notifier).setChallenge(c);
        showToast(context, l.codeResent);
      },
      err: (f) => showToast(context, l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final challenge = ref.watch(onboardingProvider.select((s) => s.challenge));
    if (challenge == null) {
      // Opened without a pending code (e.g. after a restart): start again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoute.phone.path);
      });
      return const SizedBox.shrink();
    }
    final wait = challenge.resendAvailableAt.difference(ref.watch(clockProvider)());
    final canResend = wait <= Duration.zero;
    final showDemo = ref.watch(envProvider).useFakeData;
    final country = ref.watch(selectedCountryProvider).value;
    final phone = country == null
        ? challenge.phoneE164
        : PhoneRules.display(challenge.phoneE164, dialCode: country.dialCode, sample: country.sample);

    final login = challenge.purpose == OtpPurpose.login;
    final phonePath = login ? '${AppRoute.phone.path}?mode=login' : AppRoute.phone.path;

    return JFlowScaffold(
      onBack: () => context.go(phonePath),
      backLabel: l.back,
      bottomPadded: false,
      trailing: JPillButton(label: phone, onPressed: () => context.go(phonePath)),
      bottom: JKeypad(
        enabled: !_busy,
        onDigit: _digit,
        onBackspace: () => setState(() => _code = _code.isEmpty ? '' : _code.substring(0, _code.length - 1)),
        onClear: () => setState(() => _code = ''),
        backspaceLabel: l.back,
      ),
      children: [
        JStepHeader(
          eyebrow: login ? l.welcomeBackVerify : stepEyebrow(l, 4, l.verifyLabel),
          progress: login ? null : 4 / onboardingSteps,
          title: login ? l.logInToJarina : l.verifyYourWhatsappNumber,
          subtitle: challenge.channel == OtpChannel.sms ? l.otpSentBySms(phone) : l.otpSentTo(phone),
        ),
        if (!login) ...[const SizedBox(height: 12), accountTracker(l, 4)],
        const SizedBox(height: 18),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Shake(
                trigger: _shake,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    JCodeBoxes(value: _code, error: _error != null),
                    if (_busy) const SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: t.caption.copyWith(color: c.down)),
              ],
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  if (canResend)
                    TextButton(
                      onPressed: () => _resend(challenge.channel),
                      child: Text(
                        l.resendCode,
                        style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JarinaIcon(JIcon.activity, size: 14, color: c.muted),
                          const SizedBox(width: 6),
                          Text(l.resendCodeIn(formatCountdown(wait)), style: t.caption.copyWith(color: c.muted)),
                        ],
                      ),
                    ),
                  if (challenge.channel == OtpChannel.whatsapp)
                    TextButton(
                      onPressed: canResend ? () => _resend(OtpChannel.sms) : null,
                      child: Text(
                        l.sendBySmsInstead,
                        style: t.caption.copyWith(fontWeight: FontWeight.w600, color: canResend ? c.ink : c.muted),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (showDemo) ...[
          const SizedBox(height: 12),
          JCallout(text: l.demoCodeHint(FakeBackend.demoCode), icon: JIcon.key),
        ],
      ],
    );
  }
}
