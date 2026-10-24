import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/features/crypto/application/crypto_state.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_screen.g.dart';

/// A notification derived from transfer and order events. In production these
/// come from the server (and push); deriving them keeps the demo consistent.
class AppNotification {
  const AppNotification({required this.icon, required this.title, required this.body, required this.at});

  final JIcon icon;
  final String title;
  final String body;
  final DateTime at;
}

List<AppNotification> _derive(AppLocalizations l, List<CryptoTransfer> transfers, List<LimitOrder> orders) {
  final out = <AppNotification>[
    for (final x in transfers)
      AppNotification(
        icon: x.direction == TransferDirection.deposit ? JIcon.receive : JIcon.send,
        title:
            '${x.direction == TransferDirection.deposit ? l.deposit2 : l.withdrawal} · ${switch (x.status) {
              TransferStatus.confirming => l.confirming,
              TransferStatus.processing => l.processing,
              TransferStatus.successful => l.successful,
              TransferStatus.onHold => l.onHold,
              TransferStatus.rejected => l.rejected,
              TransferStatus.cancelled => l.cancelled,
            }}',
        body: '${x.amount} ${x.coin}${x.network == null ? '' : ' · ${x.network}'}',
        at: x.createdAt,
      ),
    for (final o in orders.where((o) => o.status == OrderStatus.filled))
      AppNotification(icon: JIcon.check, title: l.orderFilled, body: '${o.pair} · ${o.amount}', at: o.createdAt),
  ]..sort((a, b) => b.at.compareTo(a.at));
  return out;
}

@riverpod
int unreadNotifications(Ref ref) {
  final readAt = ref.watch(notificationsReadAtProvider);
  final transfers = ref.watch(cryptoTransfersProvider).value ?? const <CryptoTransfer>[];
  final orders = ref.watch(cryptoOrdersProvider).value ?? const <LimitOrder>[];
  final times = [
    for (final x in transfers) x.createdAt,
    for (final o in orders.where((o) => o.status == OrderStatus.filled)) o.createdAt,
  ];
  return readAt == null ? times.length : times.where((t) => t.isAfter(readAt)).length;
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final items = _derive(
      l,
      ref.watch(cryptoTransfersProvider).value ?? const [],
      ref.watch(cryptoOrdersProvider).value ?? const [],
    );
    final readAt = ref.watch(notificationsReadAtProvider);
    final now = ref.watch(clockProvider)();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.notifications),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 32),
        children: [
          if (items.isEmpty)
            JCard(
              child: Text(l.nothingHereYet, style: t.body.copyWith(color: c.muted)),
            )
          else
            RowsCard(
              children: [
                for (final n in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: const EdgeInsets.only(top: 2), child: JarinaIcon(n.icon, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: t.body.copyWith(
                                  fontWeight: readAt == null || n.at.isAfter(readAt)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              Text(n.body, style: t.caption.copyWith(color: c.muted)),
                            ],
                          ),
                        ),
                        Text(
                          activityDate(l, n.at, now: now, withTime: false),
                          style: t.caption.copyWith(color: c.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 14),
          JButton(
            label: l.markAllAsRead,
            variant: JButtonVariant.soft,
            onPressed: () => unawaited(ref.read(notificationsReadAtProvider.notifier).markAllRead()),
          ),
        ],
      ),
    );
  }
}
