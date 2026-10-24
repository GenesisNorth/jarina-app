import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/seed/country.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/language_screen.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 3 · Create your account (WhatsApp number), or log in (`?mode=login`).
/// Both send a WhatsApp code; login then asks for the 2FA code. No passwords.
class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key, this.login = false});

  final bool login;

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phone = TextEditingController();
  String? _phoneError;
  String? _formError;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit(Country country) async {
    final l = AppLocalizations.of(context);
    final err = PhoneRules.validate(_phone.text, nationalLength: country.nationalLength);
    setState(() {
      _phoneError = switch (err) {
        null => null,
        FieldError.tooShort => l.errPhoneShort,
        FieldError.tooLong => l.errPhoneLong,
        _ => l.field(err),
      };
      _formError = null;
    });
    if (err != null) return;
    setState(() => _busy = true);
    final r = await ref
        .read(authRepositoryProvider)
        .sendOtp(
          phoneE164: PhoneRules.toE164(country.dialCode, _phone.text),
          channel: OtpChannel.whatsapp,
          purpose: widget.login ? OtpPurpose.login : OtpPurpose.signup,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (challenge) {
        ref.read(onboardingProvider.notifier).setChallenge(challenge);
        context.go(AppRoute.otp.path);
      },
      err: (f) => setState(() => _formError = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final country = ref.watch(selectedCountryProvider).value;
    if (country == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final digits = PhoneRules.digitsOnly(_phone.text).length;
    final lang = languageNames[Localizations.localeOf(context).languageCode]?.$2 ?? '';

    return JFlowScaffold(
      onBack: () => context.go(widget.login ? AppRoute.welcome.path : AppRoute.langpick.path),
      backLabel: l.back,
      trailing: widget.login
          ? null
          : JPillButton(
              label: '${l.countryName(country.iso)} · $lang',
              leading: JFlag.fromIso(country.iso) == null ? null : JarinaFlag(JFlag.fromIso(country.iso)!, width: 18),
              onPressed: () => context.go(AppRoute.country.path),
            ),
      children: [
        if (widget.login)
          JStepHeader(eyebrow: l.welcomeBack, title: l.logInToJarina)
        else ...[
          JStepHeader(
            eyebrow: stepEyebrow(l, 3, l.yourAccount),
            progress: 3 / onboardingSteps,
            title: l.createYourAccount,
          ),
          const SizedBox(height: 12),
          accountTracker(l, 3),
        ],
        const SizedBox(height: 18),
        AutofillGroup(
          child: JCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                      child: const Center(child: JarinaIcon(JIcon.device, size: 14, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(l.whatsappNumber, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                JTextField(
                  controller: _phone,
                  hint: country.sample,
                  large: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  inputFormatters: [_PhoneFormatter(country)],
                  errorText: _phoneError,
                  onChanged: (_) => setState(() => _phoneError = null),
                  onSubmitted: (_) => _submit(country),
                  prefix: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (JFlag.fromIso(country.iso) case final flag?) JarinaFlag(flag, width: 20),
                          const SizedBox(width: 6),
                          Text(country.dialCode, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l.phoneHint('${country.nationalLength}', country.sample),
                        style: t.caption.copyWith(color: c.muted, height: 1.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$digits/${country.nationalLength}',
                      style: t.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: digits == country.nationalLength ? c.up : c.ink2,
                      ),
                    ),
                  ],
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 8),
                  Text(_formError!, style: t.caption.copyWith(color: c.down)),
                ],
                const SizedBox(height: 16),
                JButton(
                  label: l.sendWhatsappCode,
                  trailingArrow: true,
                  loading: _busy,
                  onPressed: digits == 0 ? null : () => _submit(country),
                ),
              ],
            ),
          ),
        ),
        if (!widget.login) ...[const SizedBox(height: 14), _FeatureTiles(l: l)],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Divider(color: c.line)),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l.orContinueWith,
                  textAlign: TextAlign.center,
                  style: t.caption.copyWith(color: c.muted),
                ),
              ),
            ),
            Expanded(child: Divider(color: c.line)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: JButton(
                label: 'Google',
                variant: JButtonVariant.outline,
                height: 50,
                onPressed: () => showToast(context, l.signInComingSoon('Google')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: JButton(
                label: 'Apple',
                height: 50,
                onPressed: () => showToast(context, l.signInComingSoon('Apple')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        JNote(text: l.bankGradeEncryptionYourNumberIs, icon: JIcon.shield),
        const SizedBox(height: 10),
        Text(
          l.byContinuingYouAgreeToJarina,
          textAlign: TextAlign.center,
          style: t.caption.copyWith(color: c.muted, height: 1.5),
        ),
      ],
    );
  }
}

/// Keeps only digits, caps at the national length, groups like the sample.
class _PhoneFormatter extends TextInputFormatter {
  _PhoneFormatter(this.country);

  final Country country;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = PhoneRules.digitsOnly(newValue.text);
    if (digits.length > country.nationalLength) digits = digits.substring(0, country.nationalLength);
    final text = PhoneRules.format(digits, country.sample);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _FeatureTiles extends StatelessWidget {
  const _FeatureTiles({required this.l});

  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget tile(String label, JIcon icon, Color bg, Color fg, {PatternInk? ink}) {
      Widget body = Container(
        height: 72,
        color: bg,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JarinaIcon(icon, size: 18, color: fg),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.caption.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
            ),
          ],
        ),
      );
      if (ink != null) body = JPattern(ink: ink, opacity: 0.18, child: body);
      return Expanded(child: body);
    }

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            tile(l.ngxStocks, JIcon.stocks, c.black, Colors.white, ink: PatternInk.gold),
            tile(l.crypto247, JIcon.crypto, c.goldDeep, Colors.white, ink: PatternInk.black),
            tile(l.s6Countries, JIcon.globe, c.card, c.ink),
          ],
        ),
      ),
    );
  }
}
