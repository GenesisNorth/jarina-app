import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Logo, a headline that cycles EN → HA → FR, drifting currency symbols,
/// and the Create account / Log in actions.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const _langs = ['en', 'ha', 'fr'];
  int _shown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (mounted) setState(() => _shown = (_shown + 1) % _langs.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headline = lookupAppLocalizations(Locale(_langs[_shown])).rotatingHeadline;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _DriftingSymbols(color: c.gold)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.screenGutter),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Semantics(
                    label: 'Jarina',
                    image: true,
                    child: Image.asset(
                      'packages/jarina_ui/assets/logo/jarina-logo-${dark ? 'white' : 'dark'}-text.png',
                      width: math.min(size.width * 0.78, 340),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Fixed-height slot so the layout doesn't jump as languages rotate.
                  SizedBox(
                    height: t.title.fontSize! * 1.25 * 3,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: Text(
                        headline,
                        key: ValueKey(_shown),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: t.title.copyWith(fontSize: 24, height: 1.25, letterSpacing: -0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _langs.length; i++)
                        JTapTarget(
                          selected: i == _shown,
                          onTap: () {
                            setState(() => _shown = i);
                            unawaited(ref.read(localeSettingProvider.notifier).set(Locale(_langs[i])));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: i == _shown ? c.goldDeep : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _langs[i].toUpperCase(),
                              style: t.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: i == _shown ? Colors.white : c.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.welcomeTagline,
                    textAlign: TextAlign.center,
                    style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
                  ),
                  const Spacer(flex: 3),
                  JButton(label: l.createAccount, onPressed: () => context.go(AppRoute.country.path)),
                  const SizedBox(height: 8),
                  JButton(
                    label: l.logIn,
                    variant: JButtonVariant.ghost,
                    onPressed: () => context.go('${AppRoute.phone.path}?mode=login'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint African and crypto currency symbols drifting upward.
class _DriftingSymbols extends StatefulWidget {
  const _DriftingSymbols({required this.color});

  final Color color;

  @override
  State<_DriftingSymbols> createState() => _DriftingSymbolsState();
}

class _DriftingSymbolsState extends State<_DriftingSymbols> with SingleTickerProviderStateMixin {
  static const _symbols = ['₦', 'CFA', '₵', 'KSh', 'USh', 'SOL', 'Ξ', '₳', 'Đ', 'DH', 'R', 'Br', '₮', 'E£', '◎'];
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 28));
  final List<math.Random> _seeds = List.generate(16, (i) => math.Random(i * 7919));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "Reduce motion": show a still arrangement instead.
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      unawaited(_c.repeat());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _SymbolsPainter(
          _c,
          widget.color,
          _seeds.map((r) => (r.nextDouble(), r.nextDouble(), r.nextDouble())).toList(),
        ),
      ),
    ),
  );
}

class _SymbolsPainter extends CustomPainter {
  _SymbolsPainter(this.anim, this.color, this.seeds) : super(repaint: anim);

  final Animation<double> anim;
  final Color color;
  final List<(double, double, double)> seeds;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < seeds.length; i++) {
      final (x, y, s) = seeds[i];
      // Lower half of the screen only, so text above stays clean.
      final top = size.height * 0.5;
      final travel = size.height * 0.42;
      final progress = (y + anim.value * (0.4 + s * 0.6)) % 1;
      final dy = top + travel * (1 - progress);
      final opacity = math.sin(progress * math.pi) * (0.12 + s * 0.22);
      final tp = TextPainter(
        text: TextSpan(
          text: _DriftingSymbolsState._symbols[i % _DriftingSymbolsState._symbols.length],
          style: TextStyle(
            fontFamily: TypeTokens.family,
            fontFamilyFallback: JarinaText.fallbackFamilies,
            package: 'jarina_ui',
            fontSize: 18 + s * 30,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x * size.width - tp.width / 2, dy));
    }
  }

  @override
  bool shouldRepaint(_SymbolsPainter old) => old.color != color;
}
