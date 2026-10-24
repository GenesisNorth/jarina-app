import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 5 · Personal details.
class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({super.key});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  late final KycDraft _draft = ref.read(kycDraftStoreProvider);
  late final _first = TextEditingController(text: _draft.firstName);
  late final _middle = TextEditingController(text: _draft.middleName);
  late final _last = TextEditingController(text: _draft.lastName);
  late final _dob = TextEditingController(text: _draft.dob);
  late final _email = TextEditingController(text: _draft.email);
  Map<String, String?> _errors = const {};
  bool _busy = false;
  String? _formError;

  @override
  void dispose() {
    for (final c in [_first, _middle, _last, _dob, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    String? msg(FieldError? e, {String? special}) => e == null ? null : (special ?? l.field(e));
    final nameErr = NameRules.validate(_first.text);
    final errors = {
      'first': msg(nameErr, special: nameErr == FieldError.invalidFormat ? l.errNameChars : null),
      'middle': msg(NameRules.validate(_middle.text, optional: true), special: l.errNameChars),
      'last': msg(
        NameRules.validate(_last.text),
        special: NameRules.validate(_last.text) == FieldError.invalidFormat ? l.errNameChars : null,
      ),
      'dob': msg(DobRules.validate(_dob.text, today: DateTime.now())),
      'email': msg(
        EmailRules.validate(_email.text),
        special: EmailRules.validate(_email.text) == FieldError.invalidFormat ? l.errEmail : null,
      ),
    };
    setState(() {
      _errors = errors;
      _formError = null;
    });
    if (errors.values.any((e) => e != null)) return;

    setState(() => _busy = true);
    final draft = ref
        .read(kycDraftStoreProvider)
        .copyWith(
          firstName: _first.text.trim(),
          middleName: _middle.text.trim(),
          lastName: _last.text.trim(),
          dob: _dob.text,
          email: _email.text.trim(),
        );
    await ref.read(kycDraftStoreProvider.notifier).save(draft);
    final r = await ref
        .read(kycRepositoryProvider)
        .submitPersonalDetails(
          PersonalDetails(
            firstName: draft.firstName,
            middleName: draft.middleName.isEmpty ? null : draft.middleName,
            lastName: draft.lastName,
            dateOfBirth: DobRules.parse(draft.dob)!,
            email: draft.email,
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) => advanceKyc(context, ref, AppRoute.username),
      err: (f) async => setState(() => _formError = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    return JFlowScaffold(
      trailing: const HelpButton(),
      bottom: JButton(label: l.continueLabel, trailingArrow: true, loading: _busy, onPressed: _submit),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 5, l.verification),
          progress: 5 / onboardingSteps,
          title: l.personalDetails,
          subtitle: l.enterYourNameExactlyAsIt,
        ),
        const SizedBox(height: 12),
        kycTracker(l, 5),
        const SizedBox(height: 18),
        AutofillGroup(
          child: JCard(
            child: Column(
              children: [
                JTextField(
                  label: l.firstName,
                  controller: _first,
                  hint: 'Aminu',
                  errorText: _errors['first'],
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  maxLength: 50,
                ),
                const SizedBox(height: 14),
                JTextField(
                  label: l.middleNameOptional,
                  controller: _middle,
                  errorText: _errors['middle'],
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.middleName],
                  maxLength: 50,
                ),
                const SizedBox(height: 14),
                JTextField(
                  label: l.lastName,
                  controller: _last,
                  hint: 'Bello',
                  errorText: _errors['last'],
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  maxLength: 50,
                ),
                const SizedBox(height: 14),
                JTextField(
                  label: l.dateOfBirth,
                  controller: _dob,
                  hint: l.dobHint,
                  errorText: _errors['dob'],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.birthday],
                  inputFormatters: [_DobFormatter()],
                ),
                const SizedBox(height: 14),
                JTextField(
                  label: l.email,
                  controller: _email,
                  hint: 'you@example.com',
                  errorText: _errors['email'],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  onSubmitted: (_) => _submit(),
                  maxLength: 120,
                ),
              ],
            ),
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: 10),
          Text(_formError!, style: context.text.caption.copyWith(color: c.down)),
        ],
        const SizedBox(height: 14),
        JNote(text: l.yourDetailsAreEncryptedAndOnly),
      ],
    );
  }
}

class _DobFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Deleting a separator should delete the digit before it.
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (newValue.text.length < oldValue.text.length && digits == oldDigits && digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.length > 8) digits = digits.substring(0, 8);
    final text = DobRules.mask(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
