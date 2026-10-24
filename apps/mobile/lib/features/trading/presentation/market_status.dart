import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// "Mon 10:00" in the user's language, for the next NGX open.
String nextOpenText(AppLocalizations l, DateTime now) {
  final open = NgxSchedule.nextOpen(now).toLocal();
  final locale = DateFormat.localeExists(l.localeName) ? l.localeName : 'en';
  return DateFormat('EEE HH:mm', locale).format(open);
}

/// "● NGX open · delayed 15 min" / "● NGX closed · opens Mon 10:00".
/// Re-checks every minute so it flips at the open and close.
class MarketStatusLine extends ConsumerStatefulWidget {
  const MarketStatusLine({super.key});

  @override
  ConsumerState<MarketStatusLine> createState() => _MarketStatusLineState();
}

class _MarketStatusLineState extends ConsumerState<MarketStatusLine> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
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
    final now = ref.watch(clockProvider)();
    final open = NgxSchedule.isOpen(now);
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: open ? c.up : c.muted, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              open ? l.ngxOpen : l.ngxClosed(nextOpenText(l, now)),
              style: context.text.caption.copyWith(color: c.muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
