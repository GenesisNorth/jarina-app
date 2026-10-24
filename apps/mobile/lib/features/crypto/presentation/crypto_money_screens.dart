import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jarina/app/router/routes.dart';
import 'package:jarina/app/widgets/crypto_widgets.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/repositories.dart';
import 'package:jarina/features/crypto/domain/crypto.dart';
import 'package:jarina/features/markets/domain/market.dart';
import 'package:jarina/features/onboarding/presentation/onboarding_common.dart';
import 'package:jarina/features/security/presentation/pin_sheet.dart';
import 'package:jarina/features/security/presentation/twofa_sheet.dart';
import 'package:jarina/features/trading/domain/trading.dart';
import 'package:jarina/features/wallets/application/portfolio.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina/l10n/messages.dart';
import 'package:jarina_core/jarina_core.dart';
import 'package:jarina_ui/jarina_ui.dart';

const _stableFirst = ['USDT', 'USDC', 'BTC', 'ETH', 'BNB', 'SOL'];

List<AssetInfo> _coins(Map<String, AssetInfo>? catalog) {
  final all = catalog?.values.where((a) => !a.isStock).toList() ?? <AssetInfo>[];
  int rank(AssetInfo a) => _stableFirst.contains(a.id) ? _stableFirst.indexOf(a.id) : 99;
  return all..sort((a, b) => rank(a).compareTo(rank(b)));
}

Currency _unitOf(String code) => Currency.crypto(code, decimals: code == 'USDT' || code == 'USDC' ? 2 : 8);

enum _PayWith { bank, card, momo }

/// Buy crypto with an external Naira payment (bank transfer, card, MoMo).
class BuyCryptoScreen extends ConsumerStatefulWidget {
  const BuyCryptoScreen({super.key});

  @override
  ConsumerState<BuyCryptoScreen> createState() => _BuyCryptoScreenState();
}

class _BuyCryptoScreenState extends ConsumerState<BuyCryptoScreen> {
  static final _min = Money.parse('2000', Currency.ngn);
  static final _max = Money.parse('5000000', Currency.ngn);

  _PayWith _pay = _PayWith.bank;
  String _coin = 'USDT';
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Money get _ngn => Money(Decimal.tryParse(_amount.text) ?? Decimal.zero, Currency.ngn);

  Future<void> _buy() async {
    final l = AppLocalizations.of(context);
    if (_pay != _PayWith.bank) {
      showToast(context, l.comingSoon);
      return;
    }
    final account = (await ref.read(walletRepositoryProvider).fundingAccount(Currency.ngn)).valueOrNull;
    if (!mounted || account == null) return;
    final testBuild = ref.read(envProvider).useFakeData;
    final paid = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.oneTimeAccount, style: context.text.h2),
            const SizedBox(height: 12),
            SummaryCard(
              rows: [
                SummaryRow(l.amount, MoneyFormat.format(_ngn), strong: true),
                SummaryRow(l.accountName, account.accountName),
                SummaryRow(l.accountNumber, account.accountNumber),
                SummaryRow(l.bankLabel, account.bankName),
              ],
            ),
            const SizedBox(height: 12),
            JNote(text: l.oneTimeAccountNote),
            const SizedBox(height: 16),
            JButton(
              label: l.copy,
              icon: JIcon.copy,
              onPressed: () => Clipboard.setData(ClipboardData(text: account.accountNumber)),
            ),
            if (testBuild)
              JButton(
                label: l.simulatePayment,
                variant: JButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(true),
              ),
          ],
        ),
      ),
    );
    if (paid != true || !mounted) return;
    // Test builds: the transfer "lands" in the Naira wallet and is swapped at the live rate.
    setState(() => _busy = true);
    final wallets = ref.read(walletRepositoryProvider);
    final crypto = ref.read(cryptoRepositoryProvider);
    await wallets.simulateDeposit(_ngn);
    final q = (await crypto.quoteSwap(_ngn, _coin)).valueOrNull;
    final tx = q == null ? null : (await crypto.swap(q, pinToken: 'external-funding')).valueOrNull;
    if (!mounted) return;
    setState(() => _busy = false);
    if (tx != null) context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final price = ref.watch(quotesProvider).value?[_coin]?.price;
    final fee = ref.watch(tradingRepositoryProvider).feeRate;
    final ngn = _ngn;
    final outOfLimits = ngn.isPositive && (ngn < _min || ngn > _max);
    final est = price == null || !ngn.isPositive
        ? Decimal.zero
        : ((ngn.amount * (Decimal.one - fee)) / price)
              .toDecimal(scaleOnInfinitePrecision: 10)
              .floor(scale: _unitOf(_coin).decimals);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.buyCrypto),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 24),
        children: [
          Text(
            l.payWith,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          JSegmented<_PayWith>(
            segments: {_PayWith.bank: l.bankTransfer, _PayWith.card: l.card, _PayWith.momo: l.mobileMoney},
            value: _pay,
            onChanged: (v) => setState(() => _pay = v),
          ),
          const SizedBox(height: 16),
          Text(
            l.buy,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          CoinChips(coins: _coins(catalog), selected: _coin, onSelected: (v) => setState(() => _coin = v)),
          const SizedBox(height: 16),
          JTextField(
            label: l.youPay,
            controller: _amount,
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
            onChanged: (_) => setState(() {}),
            errorText: outOfLimits ? l.purchaseLimits(MoneyFormat.format(_min), MoneyFormat.format(_max)) : null,
            helperText: l.purchaseLimits(MoneyFormat.format(_min), MoneyFormat.format(_max)),
            suffix: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('NGN', style: t.body),
            ),
          ),
          const SizedBox(height: 14),
          SummaryCard(
            rows: [
              SummaryRow(l.youGetEstimated, '$est $_coin', strong: true),
              if (price != null)
                SummaryRow(l.price, l.pricePerUnit(_coin, MoneyFormat.format(Money(price, Currency.ngn)))),
              SummaryRow(l.fee, '${fee * Decimal.fromInt(100)}%'),
              SummaryRow(l.creditedTo, l.yourCoinWallet(_coin)),
            ],
          ),
          const SizedBox(height: 12),
          JNote(text: l.oneTimeAccountNote),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(
          label: l.buyCoin(_coin),
          loading: _busy,
          onPressed: ngn.isPositive && !outOfLimits && est > Decimal.zero ? _buy : null,
        ),
      ),
    );
  }
}

/// Sell crypto straight to a Nigerian bank account (PIN + 2FA).
class CashOutScreen extends ConsumerStatefulWidget {
  const CashOutScreen({super.key});

  @override
  ConsumerState<CashOutScreen> createState() => _CashOutScreenState();
}

class _CashOutScreenState extends ConsumerState<CashOutScreen> {
  String _coin = 'USDT';
  String _bank = 'GTBank';
  final _amount = TextEditingController();
  final _account = TextEditingController();
  BankAccount? _verified;
  bool _verifying = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _account.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _verifying = true;
      _error = null;
    });
    final r = await ref.read(cryptoRepositoryProvider).resolveAccount(_bank, _account.text);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      _verified = r.valueOrNull;
      _error = r.isOk ? null : l.digitsCount('10');
    });
  }

  Future<void> _cashOut(BankAccount account, Money amount) async {
    final l = AppLocalizations.of(context);
    final auth = await confirmWithPinAnd2fa(
      context,
      () => confirmWithPin(context, action: '${l.cashOut} · ${MoneyFormat.format(amount)}'),
    );
    if (!mounted || auth == null) return;
    setState(() => _busy = true);
    final r = await ref
        .read(cryptoRepositoryProvider)
        .cashOut(amount: amount, account: account, pinToken: auth.$1, twofaToken: auth.$2);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (tx) => context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id}),
      err: (f) => setState(
        () => _error = switch (f) {
          BelowMinimumFailure() => l.errMinCashOut('₦15,000'),
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
    final catalog = ref.watch(catalogProvider).value;
    final available = ref.watch(balancesProvider).value?.qtyOf(_coin) ?? Decimal.zero;
    final price = ref.watch(quotesProvider).value?[_coin]?.price;
    final feeRate = ref.watch(tradingRepositoryProvider).feeRate;
    final qty = Decimal.tryParse(_amount.text) ?? Decimal.zero;
    final gross = price == null ? Money.zero(Currency.ngn) : Money(qty * price, Currency.ngn).rounded();
    final fee = gross.times(feeRate).rounded();
    final banks = ref.watch(cryptoRepositoryProvider).banks();
    final held = _coins(catalog)
        .where((a) => (ref.watch(balancesProvider).value?.qtyOf(a.id) ?? Decimal.zero) > Decimal.zero)
        .toList();
    final account = _verified;
    final ready = account != null && qty > Decimal.zero && qty <= available;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.cashOut),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 24),
        children: [
          Text(
            l.cashOutIntro,
            style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            l.sell,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          CoinChips(coins: held, selected: _coin, onSelected: (v) => setState(() => _coin = v)),
          const SizedBox(height: 16),
          JTextField(
            label: l.amount,
            controller: _amount,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}'))],
            onChanged: (_) => setState(() => _error = null),
            errorText: qty > available ? l.notEnoughBalance : null,
            helperText: l.availableAmount('$available $_coin'),
            suffix: TextButton(
              onPressed: () => setState(() => _amount.text = available.toString()),
              child: Text(l.max),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.bankLabel,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final b in banks) ...[
                  JChip(
                    label: b,
                    selected: _bank == b,
                    onTap: () => setState(() {
                      _bank = b;
                      _verified = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          JTextField(
            label: l.accountNumber,
            controller: _account,
            hint: l.digitsCount('10'),
            keyboardType: TextInputType.number,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() => _verified = null),
            helperText: account == null ? null : l.accountVerified(account.name),
            suffix: _verifying
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(onPressed: _account.text.length == 10 ? _verify : null, child: Text(l.verify)),
          ),
          const SizedBox(height: 14),
          SummaryCard(
            rows: [
              if (price != null)
                SummaryRow(l.rate, l.pricePerUnit(_coin, MoneyFormat.format(Money(price, Currency.ngn)))),
              SummaryRow(l.fee, '${feeRate * Decimal.fromInt(100)}% · ${MoneyFormat.format(fee)}'),
              SummaryRow(l.youReceive, MoneyFormat.format(gross - fee), strong: true),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: t.caption.copyWith(color: c.down, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(
          label: l.cashOut,
          icon: JIcon.lock,
          loading: _busy,
          onPressed: ready ? () => _cashOut(account, Money(qty, _unitOf(_coin))) : null,
        ),
      ),
    );
  }
}

/// Borrow Naira against crypto collateral.
class LoanScreen extends ConsumerStatefulWidget {
  const LoanScreen({super.key});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> {
  String _coin = 'BTC';
  final _amount = TextEditingController();
  int _ltvPct = 40;
  int _days = 30;
  LoanQuote? _quote;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _requote() async {
    final qty = Decimal.tryParse(_amount.text) ?? Decimal.zero;
    if (qty <= Decimal.zero) {
      setState(() => _quote = null);
      return;
    }
    final r = await ref
        .read(cryptoRepositoryProvider)
        .quoteLoan(Money(qty, _unitOf(_coin)), ltv: _ltvPct / 100, days: _days);
    if (mounted) setState(() => _quote = r.valueOrNull);
  }

  Future<void> _borrow(LoanQuote q) async {
    final l = AppLocalizations.of(context);
    final token = await confirmWithPin(context, action: '${l.borrow} · ${MoneyFormat.format(q.borrow)}');
    if (!mounted || token == null) return;
    setState(() => _busy = true);
    final r = await ref.read(cryptoRepositoryProvider).takeLoan(q, pinToken: token);
    if (!mounted) return;
    setState(() => _busy = false);
    r.when(
      ok: (tx) {
        showToast(context, l.loanTaken);
        context.pushReplacementNamed(AppRoute.receipt.name, pathParameters: {'id': tx.id});
      },
      err: (f) => showToast(context, l.failure(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final t = context.text;
    final catalog = ref.watch(catalogProvider).value;
    final balances = ref.watch(balancesProvider).value;
    final available = balances?.qtyOf(_coin) ?? Decimal.zero;
    final qty = Decimal.tryParse(_amount.text) ?? Decimal.zero;
    final collateral = _coins(catalog).take(6).toList();
    final q = _quote;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: jarinaAppBar(context, l.borrow),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 24),
        children: [
          Text(
            l.loanIntro,
            style: t.body.copyWith(color: c.muted, fontWeight: FontWeight.w400, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            l.collateral,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          CoinChips(
            coins: collateral,
            selected: _coin,
            onSelected: (v) {
              setState(() {
                _coin = v;
                _amount.clear();
                _quote = null;
              });
            },
          ),
          const SizedBox(height: 16),
          JTextField(
            label: l.collateralAmount,
            controller: _amount,
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}'))],
            errorText: qty > available ? l.notEnoughBalance : null,
            helperText: l.availableAmount('$available $_coin'),
            onChanged: (_) => _requote(),
            suffix: TextButton(
              onPressed: () {
                _amount.text = available.toString();
                _requote();
              },
              child: Text(l.max),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.loanToValue,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          JSegmented<int>(
            segments: const {25: '25%', 40: '40%', 50: '50%'},
            value: _ltvPct,
            onChanged: (v) {
              setState(() => _ltvPct = v);
              _requote();
            },
          ),
          const SizedBox(height: 16),
          Text(
            l.duration,
            style: t.caption.copyWith(fontWeight: FontWeight.w600, color: c.ink2),
          ),
          const SizedBox(height: 8),
          JSegmented<int>(
            segments: {30: l.daysCount('30'), 60: l.daysCount('60'), 90: l.daysCount('90')},
            value: _days,
            onChanged: (v) {
              setState(() => _days = v);
              _requote();
            },
          ),
          const SizedBox(height: 14),
          SummaryCard(
            rows: [
              SummaryRow(l.youBorrow, MoneyFormat.format(q?.borrow ?? Money.zero(Currency.ngn)), strong: true),
              SummaryRow(
                l.interest,
                '${l.perMonth('3.5%')} · ${MoneyFormat.format(q?.interest ?? Money.zero(Currency.ngn))}',
              ),
              SummaryRow(l.totalToRepay, MoneyFormat.format(q?.totalToRepay ?? Money.zero(Currency.ngn))),
              SummaryRow(
                l.liquidationPrice,
                q == null ? '—' : l.pricePerUnit(_coin, MoneyFormat.format(q.liquidationPrice)),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(SpacingTokens.screenGutter, 8, SpacingTokens.screenGutter, 12),
        child: JButton(
          label: l.borrow,
          loading: _busy,
          onPressed: q != null && qty <= available ? () => _borrow(q) : null,
        ),
      ),
    );
  }
}
