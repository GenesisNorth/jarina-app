import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/seed/country.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Step 1 · Where do you live? Full-flag tiles.
class CountryScreen extends ConsumerWidget {
  const CountryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final countries = ref.watch(countriesProvider);
    final selected = ref.watch(onboardingProvider.select((s) => s.countryIso));

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.welcome.path),
      backLabel: l.back,
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 1, l.yourCountry),
          progress: 1 / onboardingSteps,
          title: l.whereDoYouLive,
          subtitle: l.chooseYourCountryWeLlShow,
        ),
        const SizedBox(height: 22),
        countries.when(
          data: (list) => LayoutBuilder(
            builder: (context, box) {
              // 3 per row on phones, 2 when large text makes names wrap badly.
              final cols = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 3;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: [
                  for (final country in list)
                    _FlagTile(
                      country: country,
                      name: l.countryName(country.iso),
                      selected: selected == country.iso,
                      onTap: () async {
                        await ref.read(onboardingProvider.notifier).setCountry(country.iso);
                        // Default the app language to the country's first language.
                        final current = ref.read(localeSettingProvider)?.languageCode;
                        if (current == null || !country.languages.contains(current)) {
                          await ref.read(localeSettingProvider.notifier).set(Locale(country.languages.first));
                        }
                        if (context.mounted) context.go(AppRoute.langpick.path);
                      },
                    ),
                ],
              );
            },
          ),
          loading: () => const Center(
            child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
          ),
          error: (_, _) => Text(l.errGeneric),
        ),
      ],
    );
  }
}

class _FlagTile extends StatelessWidget {
  const _FlagTile({required this.country, required this.name, required this.selected, required this.onTap});

  final Country country;
  final String name;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final flag = JFlag.fromIso(country.iso);
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => unawaited(onTap()),
        child: AnimatedScale(
          scale: selected ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (flag != null)
                  SvgPicture.asset(
                    flag.asset,
                    fit: BoxFit.cover,
                    // Togo's star is in the left canton; keep it in the square crop.
                    alignment: country.iso == 'TG' ? Alignment.centerLeft : Alignment.center,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.45, 1],
                      colors: [Colors.transparent, Color(0xB317181C)],
                    ),
                  ),
                ),
                Positioned(
                  left: 9,
                  right: 9,
                  bottom: 8,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.15,
                      shadows: const [Shadow(color: Color(0x99000000), blurRadius: 6)],
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2))],
                      ),
                      child: const Center(child: JarinaIcon(JIcon.check, size: 14, color: BrandColors.black)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
