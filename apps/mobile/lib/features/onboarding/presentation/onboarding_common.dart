import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Onboarding is 12 steps: country, language, account, WhatsApp OTP, details,
/// username, identity, liveness, address, PIN, confirm PIN, 2FA.
const onboardingSteps = 12;

String stepEyebrow(AppLocalizations l, int step, String section) =>
    l.stepOfSection('$step', '$onboardingSteps', section);

/// Tracker for steps 3–4 (before KYC).
JStepTracker accountTracker(AppLocalizations l, int step) => JStepTracker(
  items: [
    JTrackerItem(number: '1', label: l.country, state: JStepState.done),
    JTrackerItem(number: '2', label: l.language, state: JStepState.done),
    JTrackerItem(number: '3', label: l.account, state: step > 3 ? JStepState.done : JStepState.current),
    JTrackerItem(number: '4', label: l.whatsapp, state: step == 4 ? JStepState.current : JStepState.todo),
    JTrackerItem(number: '5–12', label: l.verification, state: JStepState.todo),
  ],
);

/// Tracker for KYC steps 5–12. [step] past 12 marks everything done.
JStepTracker kycTracker(AppLocalizations l, int step) {
  JStepState s(int from, [int? to]) {
    final end = to ?? from;
    if (step > end) return JStepState.done;
    if (step >= from) return JStepState.current;
    return JStepState.todo;
  }

  return JStepTracker(
    items: [
      JTrackerItem(number: '5', label: l.details, state: s(5)),
      JTrackerItem(number: '6', label: l.username, state: s(6)),
      JTrackerItem(number: '7', label: l.identity, state: s(7)),
      JTrackerItem(number: '8', label: l.liveness, state: s(8)),
      JTrackerItem(number: '9', label: l.address, state: s(9)),
      JTrackerItem(number: '10–11', label: l.pin, state: s(10, 11)),
      JTrackerItem(number: '12', label: l.s2fa, state: s(12)),
    ],
  );
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 3)));
}

/// Help pill in KYC top bars.
class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return JPillButton(label: l.help, icon: JIcon.help, onPressed: () => showToast(context, l.helpSoon));
  }
}

/// Plays a short horizontal shake, e.g. on a wrong code.
class Shake extends StatefulWidget {
  const Shake({required this.child, required this.trigger, super.key});

  final Widget child;

  /// Increment to play the shake once.
  final int trigger;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && !MediaQuery.disableAnimationsOf(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) {
      final t = _c.value;
      final dx = (1 - t) * 10 * math.sin(t * 6 * math.pi);
      return Transform.translate(offset: Offset(dx, 0), child: child);
    },
    child: widget.child,
  );
}
