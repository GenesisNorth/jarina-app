import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Native name and English name of each supported language.
const languageNames = {
  'en': ('English', 'English'),
  'ha': ('Harshen Hausa', 'Hausa'),
  'fr': ('Français', 'French'),
};

/// Step 2 · Choose your language (only the selected country's languages).
/// Picking a language switches the app immediately, so the user sees it.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final country = ref.watch(selectedCountryProvider).value;
    final current = Localizations.localeOf(context).languageCode;

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.country.path),
      backLabel: l.back,
      bottom: JButton(
        label: l.continueLabel,
        onPressed: country == null ? null : () => context.go(AppRoute.phone.path),
      ),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 2, l.language),
          progress: 2 / onboardingSteps,
          leading: country == null
              ? null
              : Row(
                  children: [
                    if (JFlag.fromIso(country.iso) case final flag?) JarinaFlag(flag, width: 36),
                    const SizedBox(width: 10),
                    Text(l.countryName(country.iso), style: t.body.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
          title: l.chooseYourLanguage,
          subtitle: l.jarinaWillUseThisLanguageOn,
        ),
        const SizedBox(height: 22),
        if (country != null)
          JCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: [
                for (final (i, code) in country.languages.indexed) ...[
                  if (i > 0) Divider(indent: 18, endIndent: 18, color: c.line),
                  _LanguageRow(
                    code: code,
                    selected: code == current,
                    onTap: () => unawaited(ref.read(localeSettingProvider.notifier).set(Locale(code))),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.code, required this.selected, required this.onTap});

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final (native, english) = languageNames[code] ?? (code, code);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: native,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  code.toUpperCase(),
                  style: t.caption.copyWith(fontWeight: FontWeight.w700, color: c.ink),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(native, style: t.body.copyWith(fontSize: 16)),
                    Text(english, style: t.caption.copyWith(color: c.muted)),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: selected
                    ? JarinaIcon(JIcon.check, key: const ValueKey(1), size: 22, color: c.goldDeep)
                    : Container(
                        key: const ValueKey(0),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: c.line, width: 1.5),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
