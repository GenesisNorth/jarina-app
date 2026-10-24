import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/app/widgets/money_widgets.dart';
import 'package:jarina/app/widgets/settings_widgets.dart';
import 'package:jarina/core/preferences/app_preferences.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/account/presentation/more_screen.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/security/presentation/twofa_sheet.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_screen.g.dart';

@riverpod
Future<int> backupCodesLeft(Ref ref) => ref.watch(securityRepositoryProvider).backupCodesLeft();

@riverpod
Future<List<TrustedDevice>> trustedDevices(Ref ref) => ref.watch(securityRepositoryProvider).trustedDevices();

/// Verification status, security (2FA, Face ID, PIN, backup codes, devices),
/// crypto custody and preferences.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _sheet(BuildContext context, Widget child) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.bg,
    builder: (_) => child,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final p = ref.watch(profileProvider).value;
    final codes = ref.watch(backupCodesLeftProvider).value;
    final devices = ref.watch(trustedDevicesProvider).value;
    final biometrics = ref.watch(biometricsSettingProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(displayCurrencyProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final verified = Text(
      l.verified,
      style: t.caption.copyWith(color: c.up, fontWeight: FontWeight.w700),
    );

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.account),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 4, SpacingTokens.screenGutter, 32),
        children: [
          JCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: c.black,
                  child: Text(p?.initials ?? '', style: t.h2.copyWith(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text(p?.fullName ?? '', textAlign: TextAlign.center, style: t.title),
                const SizedBox(height: 4),
                Text(
                  [formatPhone(p?.phoneE164), ?p?.email].where((s) => s.isNotEmpty).join(' · '),
                  textAlign: TextAlign.center,
                  style: t.caption.copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          SettingsLabel(l.verification),
          RowsCard(
            children: [
              SettingsRow(icon: JIcon.device, title: l.phoneNumber, done: true, trailing: verified),
              SettingsRow(icon: JIcon.idcard, title: l.bvnNin, done: true, trailing: verified),
              SettingsRow(icon: JIcon.face, title: l.livenessFaceMatch, done: true, trailing: verified),
              SettingsRow(icon: JIcon.home, title: l.address, done: true, trailing: verified),
              SettingsRow(
                icon: JIcon.doc,
                title: l.proofOfAddressTier3,
                trailing: Text(
                  l.upgrade,
                  style: t.caption.copyWith(fontWeight: FontWeight.w700, color: c.ink),
                ),
                onTap: () => _sheet(context, _InfoSheet(title: l.proofOfAddressTier3, body: l.tier3Body)),
              ),
            ],
          ),
          SettingsLabel(l.security),
          RowsCard(
            children: [
              SettingsRow(
                icon: JIcon.shield,
                title: l.twoFactorAuthentication,
                subtitle: l.twofaRequiredSub,
                trailing: Switch(
                  value: true,
                  onChanged: (_) => showToast(context, l.s2faCanTBeTurnedOff),
                ),
              ),
              SettingsRow(
                icon: JIcon.face,
                title: l.faceId,
                subtitle: l.useInsteadOfPinForSmall,
                trailing: Switch(
                  value: biometrics,
                  onChanged: (v) => unawaited(ref.read(biometricsSettingProvider.notifier).set(enabled: v)),
                ),
              ),
              SettingsRow(
                icon: JIcon.lock,
                title: l.changeTransactionPin,
                onTap: () => _sheet(context, const _ChangePinSheet()),
              ),
              SettingsRow(
                icon: JIcon.key,
                title: l.backupCodes,
                value: codes == null ? null : l.backupLeft('$codes'),
                onTap: () => _sheet(context, const _BackupCodesSheet()),
              ),
              SettingsRow(
                icon: JIcon.device,
                title: l.trustedDevices,
                value: devices == null ? null : '${devices.length}',
                onTap: () => _sheet(context, const _DevicesSheet()),
              ),
            ],
          ),
          SettingsLabel(l.cryptoCustody),
          RowsCard(
            children: [
              SettingsRow(icon: JIcon.wallet, title: l.cryptoCustodyAccount, value: l.linked),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.subAccountId, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                          Text(p?.custodyAccountId ?? '—', style: t.caption.copyWith(color: c.muted)),
                        ],
                      ),
                    ),
                    StatusPill(label: l.verified, color: c.up),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.withdrawalLimit, style: t.body.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      p?.dailyWithdrawalLimit == null
                          ? '—'
                          : l.perDayTier(MoneyFormat.format(p!.dailyWithdrawalLimit!, decimals: 0), '${p.tier}'),
                      style: t.caption.copyWith(color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsLabel(l.preferences),
          RowsCard(
            children: [
              SettingsRow(
                icon: JIcon.moon,
                title: l.darkMode,
                subtitle: l.easierOnTheEyesAtNight,
                trailing: Switch(
                  value: dark,
                  onChanged: (v) =>
                      unawaited(ref.read(themeModeSettingProvider.notifier).set(v ? ThemeMode.dark : ThemeMode.light)),
                ),
              ),
              SettingsRow(
                icon: JIcon.globe,
                title: l.language,
                value: languageNames[lang],
                onTap: () => unawaited(context.pushNamed(AppRoute.language.name)),
              ),
              SettingsRow(
                icon: JIcon.swap,
                title: l.displayCurrency2,
                value: currency.code,
                onTap: () => _sheet(context, const _CurrencySheet()),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RowsCard(
            children: [
              SettingsRow(
                icon: JIcon.logout,
                title: l.logOut2,
                danger: true,
                onTap: () => unawaited(confirmLogOut(context, ref)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 20, SpacingTokens.screenGutter, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.text.title),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ),
  );
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _SheetFrame(
      title: title,
      children: [
        Text(body, style: context.text.body.copyWith(color: context.colors.muted, height: 1.5)),
        const SizedBox(height: 18),
        JButton(label: l.done, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

enum _PinStage { current, fresh, confirm }

/// Current PIN → new PIN → confirm, then the server checks the current one.
class _ChangePinSheet extends ConsumerStatefulWidget {
  const _ChangePinSheet();

  @override
  ConsumerState<_ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends ConsumerState<_ChangePinSheet> {
  _PinStage _stage = _PinStage.current;
  String _current = '';
  String _fresh = '';
  String _pin = '';
  String? _error;
  bool _busy = false;
  int _shake = 0;

  void _fail(String message, {_PinStage? back}) {
    unawaited(HapticFeedback.heavyImpact());
    setState(() {
      _error = message;
      _pin = '';
      _shake++;
      _busy = false;
      if (back != null) _stage = back;
    });
  }

  Future<void> _digit(String d) async {
    if (_busy || _pin.length >= PinRules.length) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length < PinRules.length) return;
    final l = AppLocalizations.of(context);
    switch (_stage) {
      case _PinStage.current:
        setState(() {
          _current = _pin;
          _pin = '';
          _stage = _PinStage.fresh;
        });
      case _PinStage.fresh:
        if (PinRules.validate(_pin) case final e?) return _fail(l.field(e));
        if (_pin == _current) return _fail(l.errWeakPin);
        setState(() {
          _fresh = _pin;
          _pin = '';
          _stage = _PinStage.confirm;
        });
      case _PinStage.confirm:
        if (_pin != _fresh) return _fail(l.errPinMismatch, back: _PinStage.fresh);
        setState(() => _busy = true);
        final r = await ref.read(securityRepositoryProvider).changePin(currentPin: _current, newPin: _fresh);
        if (!mounted) return;
        r.when(
          ok: (_) {
            showToast(context, l.pinChanged);
            Navigator.pop(context);
          },
          err: (f) => _fail(
            switch (f) {
              WrongPinFailure(:final attemptsLeft) => l.errWrongPin('$attemptsLeft'),
              PinLockedFailure() => l.errPinLocked,
              _ => l.failure(f),
            },
            back: _PinStage.current,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
              children: [
                Text(
                  switch (_stage) {
                    _PinStage.current => l.enterCurrentPin,
                    _PinStage.fresh => l.createNewPin,
                    _PinStage.confirm => l.confirmNewPin,
                  },
                  textAlign: TextAlign.center,
                  style: t.h2,
                ),
                const SizedBox(height: 22),
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
              ],
            ),
          ),
          JKeypad(
            enabled: !_busy,
            onDigit: (d) => unawaited(_digit(d)),
            onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
            onClear: () => setState(() => _pin = ''),
            backspaceLabel: l.back,
          ),
        ],
      ),
    );
  }
}

class _BackupCodesSheet extends ConsumerStatefulWidget {
  const _BackupCodesSheet();

  @override
  ConsumerState<_BackupCodesSheet> createState() => _BackupCodesSheetState();
}

class _BackupCodesSheetState extends ConsumerState<_BackupCodesSheet> {
  List<String>? _codes;
  bool _busy = false;

  Future<void> _regenerate() async {
    final token = await confirmWith2fa(context);
    if (token == null || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(securityRepositoryProvider).regenerateBackupCodes(twofaToken: token);
    if (!mounted) return;
    ref.invalidate(backupCodesLeftProvider);
    setState(() {
      _busy = false;
      _codes = r.valueOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final left = ref.watch(backupCodesLeftProvider).value;
    final codes = _codes;
    return _SheetFrame(
      title: l.backupCodes,
      children: [
        Text(l.backupCodesBody, style: t.body.copyWith(color: c.muted, height: 1.5)),
        const SizedBox(height: 14),
        if (codes == null)
          JCard(
            child: Text(left == null ? '…' : l.backupLeft('$left'), style: t.title, textAlign: TextAlign.center),
          )
        else ...[
          JCard(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 10,
              children: [
                for (final code in codes)
                  SelectableText(
                    '${code.substring(0, 4)} ${code.substring(4)}',
                    style: t.body.copyWith(fontFeatures: const [FontFeature.tabularFigures()], letterSpacing: 1.2),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          JButton(
            label: l.copyAll,
            icon: JIcon.copy,
            variant: JButtonVariant.soft,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: codes.join('\n')));
              if (context.mounted) showToast(context, l.codesCopied);
            },
          ),
        ],
        const SizedBox(height: 14),
        Text(
          l.newCodesReplaceOld,
          textAlign: TextAlign.center,
          style: t.caption.copyWith(color: c.muted),
        ),
        const SizedBox(height: 8),
        JButton(
          label: l.generateNewCodes,
          icon: JIcon.shield,
          loading: _busy,
          onPressed: () => unawaited(_regenerate()),
        ),
      ],
    );
  }
}

class _DevicesSheet extends ConsumerWidget {
  const _DevicesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final devices = ref.watch(trustedDevicesProvider).value ?? const <TrustedDevice>[];
    final now = ref.watch(clockProvider)();
    return _SheetFrame(
      title: l.trustedDevices,
      children: [
        Text(l.devicesBody, style: t.body.copyWith(color: c.muted, height: 1.5)),
        const SizedBox(height: 14),
        RowsCard(
          children: [
            for (final d in devices)
              SettingsRow(
                icon: JIcon.device,
                title: d.current ? l.thisPhone : d.name,
                subtitle: d.current ? null : l.lastActive(activityDate(l, d.lastSeen, now: now, withTime: false)),
                trailing: d.current
                    ? null
                    : TextButton(
                        onPressed: () async {
                          final pin = await confirmWithPin(context, action: '${l.remove} · ${d.name}');
                          if (pin == null) return;
                          await ref.read(securityRepositoryProvider).removeDevice(d.id, pinToken: pin);
                          ref.invalidate(trustedDevicesProvider);
                          if (context.mounted) showToast(context, l.deviceRemoved);
                        },
                        child: Text(l.remove, style: TextStyle(color: c.down)),
                      ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CurrencySheet extends ConsumerWidget {
  const _CurrencySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(displayCurrencyProvider);
    return _SheetFrame(
      title: l.displayCurrency2,
      children: [
        RowsCard(
          children: [
            for (final cur in Currency.homeCurrencies)
              SettingsRow(
                icon: JIcon.wallet,
                title: cur.code,
                trailing: cur == current ? JarinaIcon(JIcon.check, size: 18, color: context.colors.goldDeep) : null,
                onTap: () {
                  unawaited(ref.read(displayCurrencyProvider.notifier).set(cur));
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ],
    );
  }
}
