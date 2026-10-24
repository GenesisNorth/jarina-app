import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/router/app_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/l10n/fallback_localizations.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

class JarinaApp extends ConsumerWidget {
  const JarinaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Debug builds only: release builds handed to testers look like the real app.
    final showDev = kDebugMode && ref.watch(envProvider).showDevTools;
    return MaterialApp.router(
      title: 'Jarina',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: JarinaTheme.light(),
      darkTheme: JarinaTheme.dark(),
      themeMode: ref.watch(themeModeSettingProvider),
      locale: ref.watch(localeSettingProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...fallbackLocalizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) => showDev
          ? Stack(
              children: [
                child!,
                _DevButton(onTap: () => router.pushNamed(AppRoute.dev.name)),
              ],
            )
          : child!,
    );
  }
}

/// Small floating entry to the route index in non-prod builds.
class _DevButton extends StatelessWidget {
  const _DevButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
    right: 0,
    top: MediaQuery.sizeOf(context).height * 0.42,
    child: Material(
      color: BrandColors.gold.withValues(alpha: 0.9),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(8))),
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            'DEV',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BrandColors.black),
          ),
        ),
      ),
    ),
  );
}
