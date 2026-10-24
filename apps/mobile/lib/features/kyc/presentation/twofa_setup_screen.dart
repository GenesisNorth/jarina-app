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
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Step 12 · Turn on two-factor authentication (TOTP QR, key, backup codes).
/// Also reached later from "Account disabled".
class TwofaSetupScreen extends ConsumerStatefulWidget {
  const TwofaSetupScreen({super.key});

  @override
  ConsumerState<TwofaSetupScreen> createState() => _TwofaSetupScreenState();
}

class _TwofaSetupScreenState extends ConsumerState<TwofaSetupScreen> {
  late Future<Result<TotpSetup>> _setup = ref.read(kycRepositoryProvider).startTotpSetup();
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _showCodes = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _duringOnboarding => !ref.read(sessionProvider).onboarded;

  Future<void> _verify() async {
    final l = AppLocalizations.of(context);
    if (_code.text.length != 6) {
      setState(() => _error = l.enterCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(kycRepositoryProvider).confirmTotp(_code.text);
    if (!mounted) return;
    await r.when(
      ok: (_) async {
        await ref.read(sessionProvider.notifier).setTwofaEnabled();
        if (!mounted) return;
        if (_duringOnboarding) {
          await advanceKyc(context, ref, AppRoute.kycdone);
        } else {
          context.go(AppRoute.home.path);
        }
      },
      err: (f) async => setState(() {
        _busy = false;
        _error = l.failure(f);
      }),
    );
  }

  Future<void> _copy(String text, String done) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showToast(context, done);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final onboarding = _duringOnboarding;

    return JFlowScaffold(
      onBack: () => context.go(onboarding ? AppRoute.kyc5.path : AppRoute.home.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JButton(label: l.verifyTurnOn2fa, trailingArrow: true, loading: _busy, onPressed: _verify),
          if (onboarding)
            JButton(
              label: l.skipForNow,
              variant: JButtonVariant.ghost,
              height: 46,
              onPressed: _busy ? null : () => advanceKyc(context, ref, AppRoute.kycdone),
            ),
        ],
      ),
      children: [
        JStepHeader(
          eyebrow: onboarding ? stepEyebrow(l, 12, l.verification) : l.s2fa,
          progress: onboarding ? 1 : null,
          title: l.turnOnTwoFactorAuthentication,
          subtitle: l.s2faProtectsLoginsOnNewDevices,
        ),
        if (onboarding) ...[const SizedBox(height: 12), kycTracker(l, 12)],
        const SizedBox(height: 18),
        FutureBuilder(
          future: _setup,
          builder: (context, snap) {
            final setup = snap.data?.valueOrNull;
            if (snap.connectionState != ConnectionState.done) {
              return const JCard(
                child: SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
              );
            }
            if (setup == null) {
              return JCard(
                child: Column(
                  children: [
                    Text(l.errGeneric, style: t.body),
                    const SizedBox(height: 12),
                    JButton(
                      label: l.tryAgain,
                      variant: JButtonVariant.soft,
                      onPressed: () => setState(() => _setup = ref.read(kycRepositoryProvider).startTotpSetup()),
                    ),
                  ],
                ),
              );
            }
            return JCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(16)),
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: QrImageView(
                            data: setup.provisioningUri.toString(),
                            size: 124,
                            padding: EdgeInsets.zero,
                            semanticsLabel: l.scanWithGoogleAuthenticatorMicrosoftAuthenticator,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.scanWithGoogleAuthenticatorMicrosoftAuthenticator,
                                style: t.caption.copyWith(color: c.muted, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                Totp.groupSecret(setup.secret),
                                style: t.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () => _copy(setup.secret, l.keyCopied),
                                icon: JarinaIcon(JIcon.copy, size: 16, color: c.ink),
                                label: Text(
                                  l.copyKey,
                                  style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  JTextField(
                    label: l.enterThe6DigitCodeFrom,
                    controller: _code,
                    hint: '123 456',
                    errorText: _error,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => _verify(),
                  ),
                  if (ref.watch(envProvider).useFakeData)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(l.demoCodeHint(FakeBackend.demoCode), style: t.caption.copyWith(color: c.muted)),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            JarinaIcon(JIcon.key, size: 20, color: c.ink),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.backupCodes, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(
                                    l.saveThese8OneTimeCodes,
                                    style: t.caption.copyWith(color: c.muted, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_showCodes) ...[
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 4,
                            children: [
                              for (final code in setup.backupCodes)
                                Center(
                                  child: Text(
                                    '${code.substring(0, 4)} ${code.substring(4)}',
                                    style: t.body.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
                                  ),
                                ),
                            ],
                          ),
                          JButton(
                            label: l.copyCodes,
                            icon: JIcon.copy,
                            variant: JButtonVariant.outline,
                            height: 46,
                            onPressed: () => _copy(setup.backupCodes.join('\n'), l.codesCopied),
                          ),
                        ] else
                          JButton(
                            label: l.backupCodes,
                            icon: JIcon.eye,
                            variant: JButtonVariant.outline,
                            height: 46,
                            onPressed: () => setState(() => _showCodes = true),
                          ),
                      ],
                    ),
                  ),
                  if (onboarding) ...[
                    const SizedBox(height: 14),
                    JCallout(text: l.skip2faWarning),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
