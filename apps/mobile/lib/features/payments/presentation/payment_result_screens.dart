import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/activity/domain/transaction.dart';
import 'package:jarina/features/payments/application/payments_state.dart';
import 'package:jarina/features/payments/presentation/payments_widgets.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Sends the approved payment. Back is blocked while the request is in
/// flight so it can't be left half-done; failures offer a way back.
class SendingScreen extends ConsumerStatefulWidget {
  const SendingScreen({super.key});

  @override
  ConsumerState<SendingScreen> createState() => _SendingScreenState();
}

class _SendingScreenState extends ConsumerState<SendingScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_send()));
  }

  Future<void> _send() async {
    final p = ref.read(pendingSendProvider);
    if (p == null) {
      context.goNamed(AppRoute.transfer.name);
      return;
    }
    final r = await ref
        .read(paymentsRepositoryProvider)
        .send(p.quote, pinToken: p.pinToken, twofaToken: p.twofaToken, note: p.note);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    r.when(
      ok: (tx) {
        ref.read(pendingSendProvider.notifier).set(null);
        ref.read(lastPaymentProvider.notifier).set((p.quote, tx));
        ref.read(transferDraftProvider.notifier).reset();
        context.pushReplacementNamed(AppRoute.celebrate.name);
      },
      err: (f) => setState(
        () => _error = switch (f) {
          QuoteExpiredFailure() => l.quoteExpiredNoFundsMoved,
          InsufficientFundsFailure() => l.notEnoughBalance,
          _ => l.failure(f),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final p = ref.watch(pendingSendProvider);
    final error = _error;
    return PopScope(
      canPop: error != null,
      child: JFlowScaffold(
        centerBody: true,
        bottom: error == null
            ? null
            : JButton(label: l.tryAgain, onPressed: () => context.pushReplacementNamed(AppRoute.payconfirm.name)),
        children: [
          Center(
            child: error == null
                ? SizedBox.square(dimension: 64, child: CircularProgressIndicator(strokeWidth: 4, color: c.goldDeep))
                : Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(color: c.down, shape: BoxShape.circle),
                    child: const JarinaIcon(JIcon.activity, size: 36, color: Colors.white),
                  ),
          ),
          const SizedBox(height: 24),
          Semantics(
            liveRegion: true,
            child: Text(error ?? l.sending, textAlign: TextAlign.center, style: t.title),
          ),
          if (p != null && error == null) ...[
            const SizedBox(height: 8),
            Text(
              '${MoneyFormat.format(p.quote.amount)} · ${p.quote.recipient.name}',
              textAlign: TextAlign.center,
              style: t.body.copyWith(color: c.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Payment sent: who, how much, and when it lands.
class CelebrateScreen extends ConsumerWidget {
  const CelebrateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final last = ref.watch(lastPaymentProvider);
    void home() => context.goNamed(AppRoute.transfer.name);
    if (last == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => home());
      return Scaffold(backgroundColor: c.bg);
    }
    final (q, tx) = last;
    final r = q.recipient;
    return _ResultScaffold(
      avatar: PersonAvatar(name: r.name, color: r.avatarColor, size: 76, countryIso: r.countryIso),
      title: l.sentTo(MoneyFormat.format(q.amount, decimals: 0), r.firstName),
      body: tx.status == TxStatus.pending ? l.sentToSub : l.sentInstantSub,
      detail: q.crossBorder ? MoneyFormat.format(q.receive) : recipientSubtitle(l, r),
      onDone: home,
      txId: tx.id,
    );
  }
}

/// P2P send or request done.
class P2pDoneScreen extends ConsumerWidget {
  const P2pDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final last = ref.watch(lastP2pProvider);
    void home() => context.goNamed(AppRoute.transfer.name);
    if (last == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => home());
      return Scaffold(backgroundColor: c.bg);
    }
    return _ResultScaffold(
      avatar: PersonAvatar(name: last.name, color: 0xFFFBE9DC, size: 76),
      title: last.request ? l.requestSent : l.sentTo(last.value, last.name.split(' ').first),
      body: last.request ? l.requestSentTo(last.handle, last.value) : l.sentInstantSub,
      detail: '@${last.handle}',
      onDone: home,
      txId: last.tx?.id,
    );
  }
}

class _ResultScaffold extends StatelessWidget {
  const _ResultScaffold({
    required this.avatar,
    required this.title,
    required this.body,
    required this.detail,
    required this.onDone,
    this.txId,
  });

  final Widget avatar;
  final String title;
  final String body;
  final String detail;
  final VoidCallback onDone;
  final String? txId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final id = txId;
    return JFlowScaffold(
      centerBody: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          JButton(label: l.done, onPressed: onDone),
          if (id != null)
            JButton(
              label: l.viewReceipt,
              variant: JButtonVariant.ghost,
              height: 48,
              onPressed: () => context.pushNamed(AppRoute.receipt.name, pathParameters: {'id': id}),
            ),
        ],
      ),
      children: [
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c.up,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.bg, width: 3),
                  ),
                  child: const JarinaIcon(JIcon.check, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(title, textAlign: TextAlign.center, style: t.title),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
        ),
        const SizedBox(height: 12),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: t.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
