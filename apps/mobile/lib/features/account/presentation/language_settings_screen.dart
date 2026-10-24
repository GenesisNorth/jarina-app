import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/app/widgets/settings_widgets.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/features/account/presentation/more_screen.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// App language: the user's country's languages first, then the others.
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final country = ref.watch(selectedCountryProvider).value;
    final current = Localizations.localeOf(context).languageCode;
    final shipped = [for (final loc in supportedLocales) loc.languageCode];
    final local = [
      for (final code in country?.languages ?? const ['en', 'ha'])
        if (shipped.contains(code)) code,
    ];
    final other = [
      for (final code in shipped)
        if (!local.contains(code)) code,
    ];
    String english(String code) => switch (code) {
      'ha' => 'Hausa',
      'fr' => 'French',
      _ => 'English',
    };

    Widget group(List<String> codes) => RowsCard(
      children: [
        for (final code in codes)
          Semantics(
            selected: code == current,
            child: SettingsRow(
              icon: JIcon.globe,
              title: languageNames[code]!,
              subtitle: english(code),
              trailing: code == current ? JarinaIcon(JIcon.check, size: 18, color: c.goldDeep) : const SizedBox(),
              onTap: () => unawaited(ref.read(localeSettingProvider.notifier).set(Locale(code))),
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.language),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 0, SpacingTokens.screenGutter, 32),
        children: [
          Row(
            children: [
              if (country != null)
                if (JFlag.fromIso(country.iso) case final flag?) ...[
                  ClipRRect(borderRadius: BorderRadius.circular(3), child: JarinaFlag(flag, width: 20)),
                  const SizedBox(width: 8),
                ],
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l.languagesInCountry(country?.iso ?? 'NG'),
                    style: t.caption.copyWith(color: c.muted, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          group(local),
          if (other.isNotEmpty) ...[SettingsLabel(l.otherLanguages), group(other)],
          const SizedBox(height: 16),
          Text(l.everyScreenIsTranslatedTheHausa, style: t.caption.copyWith(color: c.muted, height: 1.5)),
        ],
      ),
    );
  }
}
