import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/asset_widgets.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// One coin wallet: balance, actions, deposit address per network, history.
class CoinScreen extends ConsumerStatefulWidget {
  const CoinScreen({required this.coin, super.key});

  final String coin;

  @override
  ConsumerState<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends ConsumerState<CoinScreen> {
  CryptoNetwork? _network;
  Future<Result<DepositAddress>>? _address;
  final GlobalKey _depositKey = GlobalKey();

  @override
  void didUpdateWidget(CoinScreen old) {
    super.didUpdateWidget(old);
    // Never show one coin's deposit address under another coin.
    if (old.coin != widget.coin) {
      _network = null;
      _address = null;
    }
  }

  void _load(CryptoNetwork n, {bool fresh = false}) {
    setState(() {
      _network = n;
      _address = ref.read(cryptoRepositoryProvider).depositAddress(widget.coin, n, fresh: fresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final asset = ref.watch(catalogProvider).value?[widget.coin];
    final quote = ref.watch(quotesProvider).value?[widget.coin];
    final qty = ref.watch(balancesProvider).value?.qtyOf(widget.coin) ?? Decimal.zero;
    final networks = ref.watch(coinNetworksProvider(widget.coin)).value ?? const <CryptoNetwork>[];
    final transfers = (ref.watch(cryptoTransfersProvider).value ?? const <CryptoTransfer>[])
        .where((x) => x.coin == widget.coin)
        .toList();
    final inOrders = reservedInOrders(ref.watch(cryptoOrdersProvider).value ?? const [], widget.coin);

    if (asset == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_network == null && networks.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _network == null) _load(networks.first);
      });
    }
    final total = Money(qty + inOrders, asset.unit);
    final ngn = quote == null ? null : Money(quote.price * (qty + inOrders), Currency.ngn).rounded();

    Widget stat(String label, Decimal v) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.caption.copyWith(color: c.muted)),
            const SizedBox(height: 2),
            Text(MoneyFormat.format(Money(v, asset.unit)).replaceAll(' ${asset.id}', ''), style: t.num),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, asset.name),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 40),
        children: [
          JCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AssetBadge(asset),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MoneyText(total, style: t.amountL.copyWith(fontSize: 26)),
                          if (ngn != null) MoneyText(ngn, decimals: 0, style: t.caption.copyWith(color: c.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [stat(l.available, qty), const SizedBox(width: 8), stat(l.inOpenOrders, inOrders)]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: JActionButton(
                  icon: JIcon.send,
                  label: l.transfer,
                  onTap: () => context.pushNamed(AppRoute.qwd.name, queryParameters: {'coin': widget.coin}),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.receive,
                  label: l.receive,
                  onTap: () => Scrollable.ensureVisible(
                    _depositKey.currentContext!,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.activity,
                  label: l.history,
                  onTap: () => context.pushNamed(AppRoute.qhist.name),
                ),
              ),
              Expanded(
                child: JActionButton(
                  icon: JIcon.swap,
                  label: l.swap,
                  onTap: () => context.pushNamed(AppRoute.qswap.name, queryParameters: {'from': widget.coin}),
                ),
              ),
            ],
          ),
          JSectionHeader(key: _depositKey, title: l.depositAddress),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final n in networks) ...[
                  JChip(label: n.label, selected: _network?.id == n.id, onTap: () => _load(n)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_address != null)
            FutureBuilder(
              future: _address,
              builder: (context, snap) {
                final a = snap.data?.valueOrNull;
                if (a == null) {
                  return const JCard(
                    child: SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
                  );
                }
                return JCard(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.line),
                        ),
                        child: QrImageView(
                          data: a.address,
                          size: 160,
                          padding: EdgeInsets.zero,
                          semanticsLabel: l.depositAddress,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.address,
                        key: const ValueKey('deposit-address'),
                        textAlign: TextAlign.center,
                        style: t.body.copyWith(fontSize: 13, letterSpacing: 0.4, fontWeight: FontWeight.w600),
                      ),
                      if (a.memo != null) ...[
                        const SizedBox(height: 10),
                        JCallout(text: '${l.memoTag}: ${a.memo}\n${l.memoRequiredNote}', icon: JIcon.key),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: JButton(
                              label: l.copy,
                              icon: JIcon.copy,
                              height: 50,
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: a.address));
                                if (context.mounted) showToast(context, l.addressCopied);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: JButton(
                              label: l.newAddress,
                              icon: JIcon.plus,
                              height: 50,
                              variant: JButtonVariant.soft,
                              onPressed: () => _load(a.network, fresh: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l.sendOnlyOn(widget.coin, a.network.label),
                        textAlign: TextAlign.center,
                        style: t.caption.copyWith(color: c.muted, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
          JSectionHeader(title: '${widget.coin} · ${l.transactionHistory}'),
          if (transfers.isEmpty)
            JCard(
              child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(children: [for (final x in transfers) TransferRow(transfer: x)]),
        ],
      ),
    );
  }
}

/// Deposit / withdrawal row with status, network and cancel for processing withdrawals.
class TransferRow extends ConsumerWidget {
  const TransferRow({required this.transfer, super.key});

  final CryptoTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final x = transfer;
    final deposit = x.direction == TransferDirection.deposit;
    final (statusText, statusColor) = transferStatus(context, x.status);
    final detail = [
      activityDate(l, x.createdAt, now: ref.watch(clockProvider)()),
      ?x.network,
      if (x.address != null) AddressRules.shorten(x.address!),
      if (x.toUser != null) '@${x.toUser}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Transform.rotate(
              angle: deposit ? 3.1416 * 0.75 : -3.1416 * 0.25,
              child: JarinaIcon(JIcon.arrowRight, size: 18, color: deposit ? c.up : c.ink),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        deposit ? l.deposit2 : l.withdrawal,
                        style: t.body.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    RowAmount(
                      child: Text(
                        '${deposit ? '+' : '−'}${x.amount} ${x.coin}',
                        style: t.num.copyWith(fontSize: 14, color: deposit ? c.up : c.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(detail, style: t.caption.copyWith(color: c.muted)),
                const SizedBox(height: 6),
                StatusPill(label: statusText, color: statusColor),
                if (x.confirmations != null && x.status == TransferStatus.confirming)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l.confirmationsOf('${x.confirmations}', '${x.requiredConfirmations}'),
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ),
                if (x.note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(x.note!, style: t.caption.copyWith(color: c.muted, height: 1.4)),
                  ),
                if (x.cancellable)
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: c.down),
                    onPressed: () async {
                      final r = await ref.read(cryptoRepositoryProvider).cancelWithdrawal(x.id);
                      if (context.mounted) {
                        showToast(
                          context,
                          r.isOk
                              ? l.withdrawalCancelled
                              : l.failure(r.when(ok: (_) => const UnknownFailure(''), err: (f) => f)),
                        );
                      }
                    },
                    child: Text(
                      l.cancelWithdrawal,
                      style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
