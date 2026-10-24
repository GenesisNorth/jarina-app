import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/features/wallets/domain/wallets.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Receive: QR + @username to get paid by other Jarina users, and requests
/// other users sent you.
class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final profile = ref.watch(profileProvider).value;
    final requests = ref.watch(paymentRequestsProvider).value ?? const <PaymentRequest>[];
    final link = profile == null ? '' : 'https://jarina.app/@${profile.username}';

    return JFlowScaffold(
      onBack: () => context.pop(),
      backLabel: l.back,
      children: [
        Center(child: Text(l.receive, style: t.h2)),
        const SizedBox(height: 16),
        JCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: c.black,
                child: Text(profile?.initials ?? '', style: t.title.copyWith(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              Text(profile?.fullName ?? '', style: t.h2),
              Text('@${profile?.username ?? ''}', style: t.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              if (link.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: QrImageView(
                    data: link,
                    size: 170,
                    padding: EdgeInsets.zero,
                    semanticsLabel: '@${profile?.username}',
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                l.anyoneOnJarinaCanScanTo,
                textAlign: TextAlign.center,
                style: t.caption.copyWith(color: c.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: JButton(
                      label: l.shareMyTag,
                      height: 50,
                      onPressed: link.isEmpty
                          ? null
                          : () => SharePlus.instance.share(ShareParams(text: l.payTagText(link))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: JButton(
                      label: l.copyLink,
                      icon: JIcon.copy,
                      height: 50,
                      variant: JButtonVariant.soft,
                      onPressed: link.isEmpty
                          ? null
                          : () async {
                              await Clipboard.setData(ClipboardData(text: link));
                              if (context.mounted) showToast(context, l.copied);
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (requests.isNotEmpty) ...[
          JSectionHeader(title: l.requestsForYou, trailing: '${requests.length}'),
          JCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                for (final (i, r) in requests.indexed) ...[
                  if (i > 0) Divider(color: c.line),
                  _RequestTile(request: r),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RequestTile extends ConsumerStatefulWidget {
  const _RequestTile({required this.request});

  final PaymentRequest request;

  @override
  ConsumerState<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends ConsumerState<_RequestTile> {
  bool _busy = false;

  Future<void> _pay() async {
    final l = AppLocalizations.of(context);
    final r = widget.request;
    final token = await confirmWithPin(context, action: '${MoneyFormat.format(r.amount)} → @${r.fromHandle}');
    if (token == null || !mounted) return;
    setState(() => _busy = true);
    final res = await ref.read(walletRepositoryProvider).payRequest(r.id, pinToken: token);
    if (!mounted) return;
    setState(() => _busy = false);
    res.when(
      ok: (tx) => context.pushNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
      err: (f) => showToast(context, f is InsufficientFundsFailure ? l.exceedsBalance : l.failure(f)),
    );
  }

  Future<void> _decline() async {
    setState(() => _busy = true);
    await ref.read(walletRepositoryProvider).declineRequest(widget.request.id);
    if (mounted) showToast(context, AppLocalizations.of(context).declined);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final r = widget.request;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.requestedAmount(r.fromName, MoneyFormat.format(r.amount)),
            style: t.body.copyWith(fontWeight: FontWeight.w700),
          ),
          if (r.note != null) Text(r.note!, style: t.caption.copyWith(color: c.muted)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: JButton(
                  label: l.decline,
                  variant: JButtonVariant.soft,
                  height: 44,
                  onPressed: _busy ? null : _decline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: JButton(label: l.pay, height: 44, loading: _busy, onPressed: _pay),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
