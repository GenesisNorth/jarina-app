import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Professional receipt with a QR the Jarina app can verify. Cross-border
/// payments show the source → destination corridor with flags.
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({required this.id, super.key});

  final String id;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final GlobalKey _boundary = GlobalKey();

  /// Shares the receipt as a PNG image, exactly as shown.
  Future<void> _share(Transaction tx) async {
    final render = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (render == null) return;
    final image = await render.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null || !mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes.buffer.asUint8List(), mimeType: 'image/png', name: 'jarina-receipt-${tx.id}.png')],
        text: 'Jarina receipt ${tx.formattedId}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final activity = ref.watch(activityProvider);
    final tx = (activity.value ?? const <Transaction>[]).where((x) => x.id == widget.id).firstOrNull;
    final profile = ref.watch(profileProvider).value;

    void back() => context.canPop() ? context.pop() : context.goNamed(AppRoute.activity.name);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: JCircleButton(icon: JIcon.arrowLeft, semanticLabel: l.back, onPressed: back),
        ),
        title: Text(l.receipt),
        actions: [
          if (tx != null)
            IconButton(
              tooltip: l.shareReceipt,
              onPressed: () => _share(tx),
              icon: Icon(Icons.adaptive.share, color: c.ink),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: tx == null
          ? Center(
              child: activity.isLoading
                  ? const CircularProgressIndicator()
                  : Text(l.receiptNotFound, style: t.body.copyWith(color: c.muted)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 40),
              children: [
                RepaintBoundary(
                  key: _boundary,
                  child: _ReceiptCard(
                    tx: tx,
                    holder: profile == null ? null : '${profile.fullName} · @${profile.username}',
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.tx, required this.holder});

  final Transaction tx;
  final String? holder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;

    final (statusText, statusColor) = switch (tx.status) {
      TxStatus.successful => (l.successful, c.up),
      TxStatus.pending => (l.pending, c.goldDeep),
      TxStatus.failed => (l.failed, c.down),
    };
    final typeLabel = switch (tx.kind) {
      TxKind.stockTrade => l.stockTrade,
      TxKind.cryptoTrade => l.cryptoTrade,
      TxKind.crossBorder => l.crossBorderTransfer,
      TxKind.p2p => l.p2pPayment,
      TxKind.deposit => l.deposit,
      TxKind.conversion => l.currencyConversion,
      TxKind.bill => l.billPayment,
    };

    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: t.caption.copyWith(color: c.goldDeep, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 11),
      ),
    );
    Widget row(String k, String v, {bool mono = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              k,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: t.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: mono ? 0.8 : null,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
    final when = activityDate(l, tx.createdAt);

    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(RadiusTokens.card),
          border: Border.all(color: c.line.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            JBrandCard(
              radius: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Image.asset('packages/jarina_ui/assets/logo/jarina-logo-white-text.png', height: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l.transactionReceipt.toUpperCase(),
                            style: t.caption.copyWith(color: Colors.white70, fontSize: 10, letterSpacing: 1.4),
                          ),
                          Text(tx.formattedId, style: t.caption.copyWith(color: Colors.white, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          JarinaIcon(JIcon.check, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: t.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tx.title,
                    textAlign: TextAlign.center,
                    style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: MoneyText(
                      tx.amount,
                      signed: true,
                      alwaysShow: true,
                      decimals: wholeFor(tx.amount),
                      style: t.amountXl.copyWith(fontSize: 36),
                    ),
                  ),
                  Text(
                    when,
                    textAlign: TextAlign.center,
                    style: t.caption.copyWith(color: c.muted, fontSize: 13),
                  ),
                  if (tx.corridor case (final from, final to)) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          _CountryEnd(iso: from, label: l.source),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: c.gold, thickness: 1.2)),
                                JarinaIcon(JIcon.arrowRight, size: 16, color: c.goldDeep),
                                Expanded(child: Divider(color: c.gold, thickness: 1.2)),
                              ],
                            ),
                          ),
                          _CountryEnd(iso: to, label: l.destination),
                        ],
                      ),
                    ),
                  ],
                  const _Perforation(),
                  section(l.transactionDetails),
                  row(l.transactionId, tx.formattedId, mono: true),
                  row(l.dateTime, when),
                  row(l.typeLabel, typeLabel),
                  row(l.channel, l.jarinaMobileApp),
                  row(l.status, statusText),
                  section(l.parties),
                  if (holder != null) row(l.accountHolder, holder!),
                  if (tx.counterparty != null) row(l.to, tx.counterparty!),
                  section(l.details),
                  row(l.description, tx.description ?? tx.subtitle),
                  if (tx.corridor case (final from, final to))
                    row(l.corridor, '${l.countryName(from)} → ${l.countryName(to)}'),
                  const _Perforation(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.line),
                        ),
                        child: QrImageView(data: tx.verifyUri.toString(), size: 92, padding: EdgeInsets.zero),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.scanToVerify, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(l.scanThisCodeInTheJarina, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                            const SizedBox(height: 4),
                            Text(
                              'TXN ${tx.formattedId}',
                              style: t.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.thisReceiptIsElectronicallyGeneratedAnd,
                    textAlign: TextAlign.center,
                    style: t.caption.copyWith(color: c.muted, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryEnd extends StatelessWidget {
  const _CountryEnd({required this.iso, required this.label});

  final String iso;
  final String label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    return Column(
      children: [
        if (JFlag.fromIso(iso) case final f?) JarinaFlag(f, width: 34),
        const SizedBox(height: 6),
        Text(l.countryName(iso), style: t.caption.copyWith(fontWeight: FontWeight.w700)),
        Text(
          label.toUpperCase(),
          style: t.caption.copyWith(fontSize: 9, letterSpacing: 1, color: context.colors.muted),
        ),
      ],
    );
  }
}

/// Dashed tear line between receipt sections.
class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: LayoutBuilder(
      builder: (_, box) {
        final n = (box.maxWidth / 9).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(n, (_) => Container(width: 5, height: 1.4, color: context.colors.line)),
        );
      },
    ),
  );
}
