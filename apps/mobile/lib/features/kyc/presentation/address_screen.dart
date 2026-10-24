import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/seed/country.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 9 · Home address: country → state/region, city, street, occupation.
class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  late final KycDraft _draft = ref.read(kycDraftStoreProvider);
  late final _city = TextEditingController(text: _draft.city);
  late final _street = TextEditingController(text: _draft.street);
  late String? _region = _draft.region;
  late String? _occupation = _draft.occupation;
  Map<String, String?> _errors = const {};
  bool _busy = false;
  String? _formError;

  static const _occupations = ['employed', 'selfEmployed', 'trader', 'student', 'other'];

  @override
  void dispose() {
    _city.dispose();
    _street.dispose();
    super.dispose();
  }

  String _occupationLabel(AppLocalizations l, String key) => switch (key) {
    'employed' => l.employed,
    'selfEmployed' => l.selfEmployed,
    'trader' => l.trader,
    'student' => l.student,
    _ => l.other,
  };

  Future<void> _submit(Country country) async {
    final l = AppLocalizations.of(context);
    String? req(String v) => v.trim().length < 2 ? l.errRequired : null;
    final errors = {
      'region': _region == null ? l.errRequired : null,
      'city': req(_city.text),
      'street': req(_street.text),
      'occupation': _occupation == null ? l.errRequired : null,
    };
    setState(() {
      _errors = errors;
      _formError = null;
    });
    if (errors.values.any((e) => e != null)) return;

    setState(() => _busy = true);
    await ref
        .read(kycDraftStoreProvider.notifier)
        .save(
          ref
              .read(kycDraftStoreProvider)
              .copyWith(
                region: _region,
                city: _city.text.trim(),
                street: _street.text.trim(),
                occupation: _occupation,
              ),
        );
    final r = await ref
        .read(kycRepositoryProvider)
        .submitAddress(
          HomeAddress(
            countryIso: country.iso,
            region: _region!,
            city: _city.text.trim(),
            street: _street.text.trim(),
            occupation: _occupation!,
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) => advanceKyc(context, ref, AppRoute.kyc5),
      err: (f) async => setState(() => _formError = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final country = ref.watch(selectedCountryProvider).value;
    if (country == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final all = ref.watch(countriesProvider).value ?? [country];

    final (regionLabel, regionHint, regionCount) = switch (country.regionWord) {
      RegionWord.state => (l.state, l.selectState, l.statesCount('${country.regions.length}')),
      RegionWord.region => (l.region, l.selectRegion, l.regionsCount('${country.regions.length}')),
      RegionWord.department => (l.department, l.selectDepartment, l.departmentsCount('${country.regions.length}')),
    };

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.kyc3.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottom: JButton(
        label: l.continueLabel,
        trailingArrow: true,
        loading: _busy,
        onPressed: () => _submit(country),
      ),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 9, l.verification),
          progress: 9 / onboardingSteps,
          title: l.homeAddress,
          subtitle: l.requiredByRegulationYouMayBe,
        ),
        const SizedBox(height: 12),
        kycTracker(l, 9),
        const SizedBox(height: 18),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    if (JFlag.fromIso(country.iso) case final flag?) JarinaFlag(flag, width: 26),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: l.countryName(country.iso),
                              style: t.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            TextSpan(
                              text: '  $regionCount',
                              style: t.caption.copyWith(color: c.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              JSelect<Country>(
                label: l.country,
                items: all,
                value: country,
                labelOf: (x) => l.countryName(x.iso),
                onChanged: (x) async {
                  if (x == country) return;
                  await ref.read(onboardingProvider.notifier).setCountry(x.iso);
                  setState(() => _region = null);
                },
              ),
              const SizedBox(height: 14),
              JSelect<String>(
                label: regionLabel,
                hint: regionHint,
                items: country.regions,
                value: country.regions.contains(_region) ? _region : null,
                labelOf: (r) => r,
                searchHint: l.search,
                errorText: _errors['region'],
                onChanged: (r) => setState(() {
                  _region = r;
                  _errors = {..._errors, 'region': null};
                }),
              ),
              const SizedBox(height: 14),
              JTextField(
                label: l.cityTown,
                controller: _city,
                hint: 'Kano',
                errorText: _errors['city'],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.addressCity],
                maxLength: 60,
              ),
              const SizedBox(height: 14),
              JTextField(
                label: l.streetAddress,
                controller: _street,
                hint: 'No. 12 Zoo Road',
                errorText: _errors['street'],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.streetAddressLine1],
                maxLength: 120,
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  l.occupation,
                  style: t.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in _occupations)
                    JChip(
                      label: _occupationLabel(l, o),
                      selected: _occupation == o,
                      onTap: () => setState(() {
                        _occupation = o;
                        _errors = {..._errors, 'occupation': null};
                      }),
                    ),
                ],
              ),
              if (_errors['occupation'] != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 6),
                  child: Text(_errors['occupation']!, style: t.caption.copyWith(color: c.down)),
                ),
            ],
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: 10),
          Text(_formError!, style: t.caption.copyWith(color: c.down)),
        ],
      ],
    );
  }
}
