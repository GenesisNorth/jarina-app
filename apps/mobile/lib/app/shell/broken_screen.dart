import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Shown in place of a widget that failed to build (release builds only).
class BrokenScreen extends StatelessWidget {
  const BrokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This can render above the app's localizations or router; fall back to English.
    final l = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final c = context.colors;
    final t = context.text;
    return ColoredBox(
      color: c.bg,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              JarinaIcon(JIcon.help, size: 32, color: c.muted),
              const SizedBox(height: 12),
              Text(l?.errorScreenTitle ?? "This screen couldn't load", textAlign: TextAlign.center, style: t.title),
              const SizedBox(height: 6),
              Text(
                l?.errGeneric ?? 'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: t.body.copyWith(color: c.muted),
              ),
              const SizedBox(height: 16),
              if (GoRouter.maybeOf(context) != null)
                TextButton(onPressed: () => context.go(AppRoute.home.path), child: Text(l?.goHome ?? 'Go to Home')),
            ],
          ),
        ),
      ),
    );
  }
}
