import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Phase { ready, capturing, captured }

/// Step 8 · Liveness check.
///
/// The capture itself will come from the KYC vendor's SDK (e.g. Smile ID),
/// which owns the camera, anti-spoofing and face match. Until that is
/// integrated this screen runs a timed stand-in and submits a fake session id.
class LivenessScreen extends ConsumerStatefulWidget {
  const LivenessScreen({super.key});

  @override
  ConsumerState<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends ConsumerState<LivenessScreen> with SingleTickerProviderStateMixin {
  late final _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  _Phase _phase = _Phase.ready;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    setState(() {
      _phase = _Phase.capturing;
      _error = null;
    });
    await _progress.forward(from: 0);
    if (mounted) setState(() => _phase = _Phase.captured);
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(kycRepositoryProvider).submitLiveness('stub-${DateTime.now().millisecondsSinceEpoch}');
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) => advanceKyc(context, ref, AppRoute.kyc4),
      err: (f) async => setState(() => _error = l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final w = MediaQuery.sizeOf(context).width;
    final ring = (w * 0.58).clamp(180.0, 260.0);

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.kyc2.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottom: switch (_phase) {
        _Phase.ready => JButton(label: l.startCamera, icon: JIcon.camera, trailingArrow: true, onPressed: _capture),
        _Phase.capturing => JButton(label: l.livenessHold, loading: true, onPressed: null),
        _Phase.captured => Row(
          children: [
            Expanded(
              child: JButton(label: l.retake, variant: JButtonVariant.soft, onPressed: _busy ? null : _capture),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: JButton(label: l.continueLabel, trailingArrow: true, loading: _busy, onPressed: _submit),
            ),
          ],
        ),
      },
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 8, l.verification),
          progress: 8 / onboardingSteps,
          title: l.livenessCheck,
          subtitle: l.takeAQuickSelfieSoWe,
        ),
        const SizedBox(height: 12),
        kycTracker(l, 8),
        const SizedBox(height: 18),
        JCard(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
          child: Column(
            children: [
              SizedBox.square(
                dimension: ring,
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _phase == _Phase.ready ? 1 : _progress.value,
                        strokeWidth: 3,
                        color: _phase == _Phase.ready ? c.ink : (_phase == _Phase.captured ? c.up : c.gold),
                        backgroundColor: c.line,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: c.fill, shape: BoxShape.circle),
                          child: Center(
                            child: _phase == _Phase.captured
                                ? JarinaIcon(JIcon.check, size: ring * 0.3, color: c.up)
                                : JarinaIcon(JIcon.user, size: ring * 0.32, color: c.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Semantics(
                liveRegion: true,
                child: Text(
                  switch (_phase) {
                    _Phase.ready => l.goodLightNoHatOrGlasses,
                    _Phase.capturing => l.livenessHold,
                    _Phase.captured => l.selfieCaptured,
                  },
                  textAlign: TextAlign.center,
                  style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: t.caption.copyWith(color: c.down)),
        ],
        const SizedBox(height: 14),
        JNote(text: l.yourDetailsAreEncryptedAndOnly),
      ],
    );
  }
}
