import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/core/security/app_security.dart';
import 'package:jarina/core/session/session_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

/// Wraps the whole app: the PIN lock, a privacy cover while the app is in the
/// app switcher, and a one-time warning on rooted / jailbroken phones.
class SecurityShell extends ConsumerStatefulWidget {
  const SecurityShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SecurityShell> createState() => _SecurityShellState();
}

class _SecurityShellState extends ConsumerState<SecurityShell> {
  late final AppLifecycleListener _lifecycle;
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onInactive: () => setState(() => _covered = true),
      onHide: () => ref.read(appLockProvider.notifier).backgrounded(),
      onShow: () => ref.read(appLockProvider.notifier).resumed(),
      onResume: () => setState(() => _covered = false),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    final compromised = ref.watch(deviceCompromisedProvider).value ?? false;
    final seen = ref.watch(compromisedWarningSeenProvider);
    final signedIn = ref.watch(sessionProvider.select((s) => s.signedIn));
    return Stack(
      children: [
        // Hidden from screen readers and taps while locked.
        ExcludeSemantics(
          excluding: locked,
          child: AbsorbPointer(absorbing: locked, child: widget.child),
        ),
        if (locked) const Positioned.fill(child: _LockScreen()),
        if (!locked && compromised && !seen && signedIn) const Positioned.fill(child: _CompromisedNotice()),
        if (_covered) const Positioned.fill(child: _PrivacyCover()),
      ],
    );
  }
}

class _PrivacyCover extends StatelessWidget {
  const _PrivacyCover();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: BrandColors.black,
    child: Center(
      child: Text(
        'Jarina',
        textDirection: TextDirection.ltr,
        style: TextStyle(color: BrandColors.gold, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1),
      ),
    ),
  );
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen();

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  String _pin = '';
  String? _error;
  bool _busy = false;
  int _shake = 0;

  Future<void> _logOut({String? message}) async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(sessionProvider.notifier).signOut();
    if (message != null && mounted) showToast(context, message);
  }

  Future<void> _digit(String d) async {
    if (_busy || _pin.length >= PinRules.length) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length < PinRules.length) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(securityRepositoryProvider).verifyPin(_pin);
    if (!mounted) return;
    switch (r) {
      case Ok():
        ref.read(appLockProvider.notifier).unlock();
      case Err(failure: PinLockedFailure()):
        await _logOut(message: l.lockedOutLogInAgain);
      case Err(:final failure):
        unawaited(HapticFeedback.heavyImpact());
        setState(() {
          _busy = false;
          _pin = '';
          _shake++;
          _error = failure is WrongPinFailure ? l.errWrongPin('${failure.attemptsLeft}') : l.failure(failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final name = ref.watch(profileProvider).value?.firstName;
    return Material(
      color: c.bg,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: c.black, shape: BoxShape.circle),
              child: JarinaIcon(JIcon.lock, size: 28, color: c.gold),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                name == null ? l.welcomeBack : '${l.welcomeBack}, $name',
                textAlign: TextAlign.center,
                style: t.h2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.unlockSub,
              style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 24),
            Shake(
              trigger: _shake,
              child: JPinDots(filled: _pin.length, error: _error != null),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 20,
              child: _busy
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Semantics(
                      liveRegion: true,
                      child: Text(_error ?? '', style: t.caption.copyWith(color: c.down)),
                    ),
            ),
            const Spacer(),
            JKeypad(
              enabled: !_busy,
              onDigit: (d) => unawaited(_digit(d)),
              onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
              onClear: () => setState(() => _pin = ''),
              backspaceLabel: l.back,
            ),
            TextButton(onPressed: () => unawaited(_logOut()), child: Text(l.notYouLogOut)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CompromisedNotice extends ConsumerWidget {
  const _CompromisedNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(SpacingTokens.screenGutter),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(RadiusTokens.card)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                JarinaIcon(JIcon.shield, size: 30, color: c.down),
                const SizedBox(height: 12),
                Text(l.compromisedTitle, style: t.title),
                const SizedBox(height: 6),
                Text(l.compromisedBody, style: t.body.copyWith(color: c.muted, height: 1.5)),
                const SizedBox(height: 16),
                JButton(
                  label: l.understood,
                  onPressed: () => unawaited(ref.read(compromisedWarningSeenProvider.notifier).acknowledge()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
