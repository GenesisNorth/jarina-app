import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// "You're verified": tier tiles and shortcuts, then into the app.
class VerifiedScreen extends ConsumerStatefulWidget {
  const VerifiedScreen({super.key});

  @override
  ConsumerState<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends ConsumerState<VerifiedScreen> {
  bool _busy = false;

  Future<void> _finish() async {
    setState(() => _busy = true);
    await ref.read(kycDraftStoreProvider.notifier).clear();
    await ref.read(sessionProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoute.home.path);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final twofa = ref.watch(sessionProvider.select((s) => s.twofaEnabled));
    final nigeria = ref.watch(selectedCountryProvider).value?.isNigeria ?? false;

    return JFlowScaffold(
      bottom: JButton(label: l.goToJarina, loading: _busy, onPressed: _finish),
      children: [
        // Text and badge sit side by side, so they can't overlap on narrow phones.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: JStepHeader(
                eyebrow: l.tier2AllSet,
                title: l.youReVerified,
                subtitle: twofa ? l.identityConfirmedAnd2faIsOn : l.identityConfirmedYourAccountIsDisabled,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: c.gold,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: c.gold.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Center(child: JarinaIcon(JIcon.shield, size: 30, color: BrandColors.black)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        kycTracker(l, twofa ? 13 : 12),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth < 330 || MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 2 : 3;
            final tiles = [
              _Tile(l.tier1, l.phoneBvn, nigeria ? l.s50kDay : null, JIcon.check, _TileStyle.black, done: true),
              _Tile(l.tier2, l.idSelfie, nigeria ? l.s5mDay : null, JIcon.check, _TileStyle.gold, done: true),
              _Tile(l.tier3, l.proofOfIncome, l.upgrade, JIcon.up, _TileStyle.white),
              _Tile(l.s2fa, l.authenticator, twofa ? l.onLabel : null, JIcon.shield, _TileStyle.gold, done: twofa),
              _Tile(l.addMoney, l.bankOrMomo, null, JIcon.plus, _TileStyle.white),
              _Tile(l.buyStocks, l.ngxShares, null, JIcon.stocks, _TileStyle.black),
              _Tile(l.buyCrypto, l.btcUsdt, null, JIcon.crypto, _TileStyle.white),
              _Tile(l.sendMoney, l.s6Countries, null, JIcon.send, _TileStyle.black),
              _Tile(l.payBills, l.airtimePower, null, JIcon.bolt, _TileStyle.gold),
            ];
            return ClipRRect(
              borderRadius: BorderRadius.circular(RadiusTokens.card),
              child: GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: cols == 3 ? 0.95 : 1.4,
                children: tiles,
              ),
            );
          },
        ),
        if (!twofa) ...[
          const SizedBox(height: 14),
          JCallout(text: l.turnOnTwoFactorAuthenticationTo2, icon: JIcon.lock),
        ],
      ],
    );
  }
}

enum _TileStyle { black, gold, white }

class _Tile extends StatelessWidget {
  const _Tile(this.title, this.subtitle, this.footer, this.icon, this.style, {this.done = false});

  final String title;
  final String subtitle;
  final String? footer;
  final JIcon icon;
  final _TileStyle style;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final (bg, fg, ink) = switch (style) {
      _TileStyle.black => (c.black, Colors.white, PatternInk.gold),
      _TileStyle.gold => (c.goldDeep, Colors.white, PatternInk.black),
      _TileStyle.white => (Colors.white, c.black, PatternInk.gold),
    };
    return Semantics(
      label: [title, subtitle, ?footer].join(', '),
      excludeSemantics: true,
      child: JPattern(
        ink: ink,
        opacity: style == _TileStyle.white ? 0.12 : 0.14,
        child: Container(
          color: bg,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: style == _TileStyle.white ? c.fill : Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: JarinaIcon(icon, size: 15, color: fg)),
                  ),
                  const Spacer(),
                  if (done) JarinaIcon(JIcon.check, size: 13, color: fg.withValues(alpha: 0.8)),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.caption.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.caption.copyWith(color: fg.withValues(alpha: 0.75), fontSize: 11),
              ),
              if (footer != null)
                Text(
                  footer!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.caption.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
