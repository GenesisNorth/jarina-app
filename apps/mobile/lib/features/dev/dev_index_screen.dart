import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Non-prod route index: open any screen, flip session state to test the
/// router guards, switch theme and language.
class DevIndexScreen extends ConsumerWidget {
  const DevIndexScreen({super.key});

  static const Map<RouteGroup, String> _groups = {
    RouteGroup.preAuth: 'Onboarding (signed out)',
    RouteGroup.kyc: 'KYC (signed in, not onboarded)',
    RouteGroup.tab: 'Tabs',
    RouteGroup.app: 'App screens',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    final t = context.text;
    return Scaffold(
      appBar: AppBar(title: const Text('Route index')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _Header('Session', style: t.h2),
          SwitchListTile(
            title: const Text('Signed in'),
            value: session.signedIn,
            onChanged: (v) => notifier.update(session.copyWith(signedIn: v)),
          ),
          SwitchListTile(
            title: const Text('Onboarded (KYC done)'),
            value: session.onboarded,
            onChanged: (v) => notifier.update(session.copyWith(onboarded: v)),
          ),
          SwitchListTile(
            title: const Text('2FA on'),
            subtitle: const Text('Off → gated screens redirect to "disabled"'),
            value: session.twofaEnabled,
            onChanged: (v) => notifier.update(session.copyWith(twofaEnabled: v)),
          ),
          ListTile(
            title: const Text('Sign in fully (onboarded + 2FA)'),
            trailing: const JarinaIcon(JIcon.check),
            onTap: () => notifier.update(const SessionState(signedIn: true, onboarded: true, twofaEnabled: true)),
          ),
          _Header('Appearance', style: t.h2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {ref.watch(themeModeSettingProvider)},
              onSelectionChanged: (s) => ref.read(themeModeSettingProvider.notifier).set(s.first),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'ha', label: Text('HA')),
                ButtonSegment(value: 'fr', label: Text('FR')),
              ],
              selected: {
                ref.watch(localeSettingProvider)?.languageCode ?? Localizations.localeOf(context).languageCode,
              },
              onSelectionChanged: (s) => ref.read(localeSettingProvider.notifier).set(Locale(s.first)),
            ),
          ),
          for (final g in _groups.entries) ...[
            _Header('${g.value} · ${AppRoute.values.where((r) => r.group == g.key).length}', style: t.h2),
            for (final r in AppRoute.values.where((r) => r.group == g.key))
              ListTile(
                dense: true,
                title: Text(r.name, style: t.body.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(r.spec, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: r.gated ? const JarinaIcon(JIcon.lock, size: 18) : null,
                onTap: () => r.group == RouteGroup.tab
                    ? context.goNamed(r.name)
                    : context.pushNamed(r.name, pathParameters: r.sampleParams),
              ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.label, {required this.style});

  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(label, style: style),
  );
}
