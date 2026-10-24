import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Stand-in for a screen not built yet. Shows the prototype id and spec so
/// every route is reachable and checkable from Phase 0. Each phase replaces
/// these with the real feature screens.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.route, this.params = const {}, super.key});

  final AppRoute route;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final isTab = route.group == RouteGroup.tab;
    return Scaffold(
      appBar: isTab ? null : AppBar(title: Text(route.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 16, SpacingTokens.screenGutter, 120),
          children: [
            if (isTab) Text(route.name[0].toUpperCase() + route.name.substring(1), style: t.largeTitle),
            if (isTab) const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.black,
                borderRadius: BorderRadius.circular(RadiusTokens.card),
                image: const DecorationImage(
                  image: AssetImage('packages/jarina_ui/assets/logo/jarina-mark-gold.png'),
                  alignment: Alignment.centerRight,
                  opacity: 0.12,
                  scale: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge(label: route.name, color: c.gold, ink: c.black),
                        const SizedBox(width: 8),
                        if (route.gated) const _Badge(label: '2FA gated', color: Colors.white24, ink: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(route.spec, style: t.body.copyWith(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Not built yet · ${route.path}', style: t.caption.copyWith(color: Colors.white60)),
                  ],
                ),
              ),
            ),
            if (params.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Params', style: t.h2),
              const SizedBox(height: 8),
              for (final e in params.entries) Text('${e.key}: ${e.value}', style: t.body.copyWith(color: c.muted)),
            ],
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pushNamed(AppRoute.dev.name),
              child: const Text('Open route index'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.ink});

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(RadiusTokens.chip)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        label,
        style: context.text.caption.copyWith(color: ink, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
