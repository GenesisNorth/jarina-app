import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/kyc/presentation/kyc_common.dart';
import 'package:jarina/features/onboarding/application/onboarding_controller.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

enum _Availability { idle, checking, available, taken }

/// Step 6 · Create your @username with live availability.
class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  late final _ctrl = TextEditingController(text: ref.read(kycDraftStoreProvider).username);
  Timer? _debounce;
  _Availability _status = _Availability.idle;
  FieldError? _ruleError;
  String? _formError;
  bool _busy = false;

  /// Drops responses for anything but the latest query (typing is faster than the network).
  int _query = 0;

  @override
  void initState() {
    super.initState();
    if (_ctrl.text.isNotEmpty) _onChanged(_ctrl.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  String get _handle => UsernameRules.normalize(_ctrl.text);

  void _onChanged(String _) {
    _debounce?.cancel();
    final err = UsernameRules.validate(_handle);
    setState(() {
      _ruleError = _handle.isEmpty ? null : err;
      _formError = null;
      _status = err == null ? _Availability.checking : _Availability.idle;
    });
    if (err != null) return;
    final q = ++_query;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final r = await ref.read(kycRepositoryProvider).isUsernameAvailable(_handle);
      if (!mounted || q != _query) return;
      setState(() => _status = (r.valueOrNull ?? false) ? _Availability.available : _Availability.taken);
    });
  }

  void _pick(String handle) {
    _ctrl.text = handle;
    _ctrl.selection = TextSelection.collapsed(offset: handle.length);
    _onChanged(handle);
  }

  Future<void> _claim() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    final r = await ref.read(kycRepositoryProvider).claimUsername(_handle);
    if (!mounted) return;
    setState(() => _busy = false);
    await r.when(
      ok: (_) async {
        final store = ref.read(kycDraftStoreProvider.notifier);
        await store.save(ref.read(kycDraftStoreProvider).copyWith(username: _handle));
        if (mounted) await advanceKyc(context, ref, AppRoute.kyc2);
      },
      err: (f) async => setState(() {
        _status = _Availability.taken;
        _formError = l.usernameTaken(_handle);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final draft = ref.watch(kycDraftStoreProvider);
    final suggestions = UsernameRules.suggestions(draft.firstName, draft.lastName);
    final ok = _status == _Availability.available;

    final String? helper;
    final Color helperColor;
    switch ((_ruleError, _status)) {
      case (final FieldError e, _):
        helper = e == FieldError.invalidFormat ? l.errUsernameChars : l.field(e);
        helperColor = c.down;
      case (_, _Availability.checking):
        helper = l.usernameChecking;
        helperColor = c.muted;
      case (_, _Availability.available):
        helper = l.usernameAvailable(_handle);
        helperColor = c.up;
      case (_, _Availability.taken):
        helper = _formError ?? l.usernameTaken(_handle);
        helperColor = c.down;
      case (_, _Availability.idle):
        helper = l.s320CharactersLettersNumbersOr;
        helperColor = c.muted;
    }

    return JFlowScaffold(
      onBack: () => context.go(AppRoute.kyc1.path),
      backLabel: l.back,
      trailing: const HelpButton(),
      bottom: JButton(
        label: ok ? l.claimHandle(_handle) : l.continueLabel,
        trailingArrow: true,
        loading: _busy,
        onPressed: ok ? _claim : null,
      ),
      children: [
        JStepHeader(
          eyebrow: stepEyebrow(l, 6, l.verification),
          progress: 6 / onboardingSteps,
          title: l.createYourUsername,
          subtitle: l.yourUsernameLetsOtherJarinaUsers,
        ),
        const SizedBox(height: 12),
        kycTracker(l, 6),
        const SizedBox(height: 18),
        JCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              JTextField(
                label: l.username,
                controller: _ctrl,
                hint: l.yourName,
                large: true,
                autofocus: _ctrl.text.isEmpty,
                maxLength: UsernameRules.maxLength,
                keyboardType: TextInputType.visiblePassword, // no autocorrect / caps
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_.]')),
                  TextInputFormatter.withFunction((o, n) => n.copyWith(text: n.text.toLowerCase())),
                ],
                onChanged: _onChanged,
                onSubmitted: (_) => ok ? _claim() : null,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 4),
                  child: Text('@', style: t.title.copyWith(fontSize: 22, color: c.goldDeep)),
                ),
                suffix: switch (_status) {
                  _Availability.checking => const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  _Availability.available => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: c.up,
                      child: const JarinaIcon(JIcon.check, size: 14, color: Colors.white),
                    ),
                  ),
                  _ => null,
                },
              ),
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  helper,
                  style: t.caption.copyWith(color: helperColor, fontWeight: FontWeight.w600),
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l.suggestions,
                  style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions) JChip(label: '@$s', selected: _handle == s, onTap: () => _pick(s)),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _PreviewCard(name: draft.displayName, handle: _handle.isEmpty ? l.yourName : _handle),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JNote(text: l.yourUsernameIsPublicToPeople, icon: JIcon.eye),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.name, required this.handle});

  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.text;
    const gold = BrandColors.gold;
    Widget perk(JIcon icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          JarinaIcon(icon, size: 14, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: t.caption.copyWith(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
          ),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: JPattern(
        opacity: 0.1,
        child: Container(
          color: BrandColors.black,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isEmpty ? '@' : name.split(' ').map((w) => w[0]).take(2).join(),
                      style: t.body.copyWith(fontWeight: FontWeight.w700, color: BrandColors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '@$handle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.body.copyWith(color: gold, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: Colors.white.withValues(alpha: 0.12)),
              perk(JIcon.receive, l.receiveNairaCediCfa),
              perk(JIcon.crypto, l.receiveCryptoFreeInstant),
              perk(JIcon.stocks, l.receiveGiftedStocks),
            ],
          ),
        ),
      ),
    );
  }
}
