import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 7 · Verify your identity: BVN / NIN / Passport (NG) or
/// National ID / Passport / Voter card elsewhere.
class IdentityScreen extends ConsumerStatefulWidget {
  const IdentityScreen({super.key});

  @override
  ConsumerState<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends ConsumerState<IdentityScreen> {
  IdType? _type;
  final _number = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  bool _numeric(IdType t) => t == IdType.bvn || t == IdType.nin;

  Future<void> _submit(IdType type) async {
    final l = AppLocalizations.of(context);
    final err = IdRules.validate(type, _number.text);
    if (err != null) {
      setState(() => _error = _numeric(type) && err == FieldError.invalidFormat ? l.digitsCount('11') : l.field(err));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref.read(kycRepositoryProvider).verifyIdentity(type, _number.text.replaceAll(' ', ''));
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) => advanceKyc(context, ref, AppRoute.kyc3),
      err: (f) async => setState(() => _error = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final country = ref.watch(selectedCountryProvider).value;
    final nigeria = country?.isNigeria ?? true;
    final types = nigeria
        ? {IdType.bvn: 'BVN', IdType.nin: 'NIN', IdType.passport: l.passport}
        : {IdType.nationalId: l.nationalId, IdType.passport: l.passport, IdType.voterCard: l.voterCard};
    final type = _type != null && types.containsKey(_type) ? _type! : types.keys.first;

    final (label, helper) = switch (type) {
      IdType.bvn => (l.bankVerificationNumberBvn, l.dial5650OnYourRegistered),
      IdType.nin => (l.nationalIdNumber, l.idHintNin),
      IdType.passport => (l.passportNumber, l.idHintPassport),
      IdType.nationalId || IdType.voterCard => (l.cardNumber, l.idHintNationalId),
    };

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.username.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottom: JButton(label: l.continueLabel, trailingArrow: true, loading: _busy, onPressed: () => _submit(type)),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 7, l.verification),
          progress: 7 / onboardingSteps,
          title: l.verifyYourIdentity,
          subtitle: nigeria ? l.nigerianResidentsVerifyWithBvnOr : l.idOtherCountries,
        ),
        const SizedBox(height: 12),
        kycTracker(l, 7),
        const SizedBox(height: 18),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JSegmented<IdType>(
                segments: types,
                value: type,
                onChanged: (v) => setState(() {
                  _type = v;
                  _number.clear();
                  _error = null;
                }),
              ),
              const SizedBox(height: 16),
              JTextField(
                key: ValueKey(type),
                label: label,
                controller: _number,
                hint: _numeric(type) ? l.digitsCount('11') : null,
                errorText: _error,
                helperText: helper,
                keyboardType: _numeric(type) ? TextInputType.number : TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                maxLength: _numeric(type) ? 11 : 20,
                inputFormatters: [
                  if (_numeric(type))
                    FilteringTextInputFormatter.digitsOnly
                  else
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _submit(type),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JNote(text: l.yourDetailsAreEncryptedAndOnly),
      ],
    );
  }
}
