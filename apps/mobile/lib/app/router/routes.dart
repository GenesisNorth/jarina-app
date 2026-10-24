/// Every screen in the app. Route names are the prototype's screen ids
/// (`jarina-mobile/docs/SCREENS.md`) so QA can compare screen-for-screen.
///
/// `logos` (asset-logo upload) is intentionally absent: it moves to the admin
/// console in production.
enum AppRoute {
  // ── Onboarding (pre-auth) ──────────────────────────────────────────────
  welcome('/welcome', RouteGroup.preAuth, 'Logo, rotating EN/HA/FR headline, Create account / Log in'),
  country('/country', RouteGroup.preAuth, 'Step 1 · Where do you live? Flag tiles'),
  langpick('/langpick', RouteGroup.preAuth, "Step 2 · Choose your language (that country's languages)"),
  phone('/phone', RouteGroup.preAuth, 'Step 3 · WhatsApp number, Google / Apple. Also login (?mode=login)'),
  otp('/otp', RouteGroup.preAuth, 'Step 4 · Verify WhatsApp number (6 digits, SMS fallback)'),
  twofa('/twofa', RouteGroup.preAuth, '2FA code at login (new device)'),

  // ── KYC (signed in, onboarding not finished) ───────────────────────────
  kyc1('/kyc1', RouteGroup.kyc, 'Step 5 · Personal details'),
  username('/username', RouteGroup.kyc, 'Step 6 · Create @username: availability, suggestions, preview'),
  kyc2('/kyc2', RouteGroup.kyc, 'Step 7 · Verify identity: BVN / NIN / Passport or national ID'),
  kyc3('/kyc3', RouteGroup.kyc, 'Step 8 · Liveness check (selfie)'),
  kyc4('/kyc4', RouteGroup.kyc, 'Step 9 · Home address: country → state/region'),
  kyc5('/kyc5', RouteGroup.kyc, 'Steps 10–11 · Create / confirm transaction PIN'),
  kyc6('/kyc6', RouteGroup.kyc, 'Step 12 · Turn on 2FA (TOTP QR, key, backup codes)'),
  kycdone('/kycdone', RouteGroup.kyc, "You're verified: tier tiles and shortcuts"),
  disabled('/disabled', RouteGroup.app, 'Account limited (2FA off)'),

  // ── Tabs (shell with bottom bar) ───────────────────────────────────────
  home('/home', RouteGroup.tab, 'Dashboard: balance card, quick actions, wallets, assets, activity'),
  stocks('/stocks', RouteGroup.tab, 'NGX portfolio, holdings, Autopilot, all stocks by sector'),
  crypto('/crypto', RouteGroup.tab, 'Crypto portfolio, holdings, crypto services'),
  wallets('/wallets', RouteGroup.tab, 'Currency + crypto wallets, filter, P2P shortcut'),
  more('/more', RouteGroup.tab, 'Profile, bills, trading tools, account, security, language, help'),
  transfer('/home/transfer', RouteGroup.tab, 'Transfers: pay-from, keypad, transfer types, beneficiaries'),
  activity('/more/activity', RouteGroup.tab, 'All transactions with filters'),

  // ── Trading ────────────────────────────────────────────────────────────
  asset('/asset/:id', RouteGroup.app, 'Asset detail: price, range chart, position, rules & alerts, Buy/Sell'),
  entry('/entry', RouteGroup.app, 'Buy / Sell (swap-style): pay-from, % slider, live quote, fee, slide', gated: true),
  picker('/picker', RouteGroup.app, 'Pick an asset (rules, alerts, trade)'),
  qpick('/qpick', RouteGroup.app, 'Pick a coin to buy'),
  qswap('/qswap', RouteGroup.app, 'Instant swap: coin sheets, % slider, flip, 15s quote ring', gated: true),
  qpro('/qpro', RouteGroup.app, 'Pro trade: pairs, candles, MA, order book, limit/market', gated: true),
  qorders('/qorders', RouteGroup.app, 'Open / filled / cancelled orders'),
  qwallets('/qwallets', RouteGroup.app, 'Crypto wallets'),
  qcoin('/qcoin/:coin', RouteGroup.app, 'Single coin: transfer, receive, history, deposit address per network'),
  qwd('/qwd', RouteGroup.app, 'Withdraw crypto (external address or Jarina user)', gated: true),
  qbuy('/qbuy', RouteGroup.app, 'Buy with bank / card / MoMo', gated: true),
  qcashout('/qcashout', RouteGroup.app, 'Cash out crypto to bank', gated: true),
  qhist('/qhist', RouteGroup.app, 'Crypto deposits, withdrawals, swaps, buy/sell'),
  qauto('/qauto', RouteGroup.app, 'Auto-swap deposits / recurring buy'),
  qloan('/qloan', RouteGroup.app, 'Crypto-backed loan', gated: true),
  qnotif('/qnotif', RouteGroup.app, 'Notifications'),
  autopilot('/autopilot', RouteGroup.app, 'Stock / Crypto Autopilot rules list'),
  rule('/rule', RouteGroup.app, 'Autopilot rule: trigger, condition, wallet, amount, repeat, expiry', gated: true),
  alerts('/alerts', RouteGroup.app, 'Price alerts + recent notifications'),
  alert('/alert', RouteGroup.app, 'New / edit price alert'),

  // ── Money movement ─────────────────────────────────────────────────────
  p2p('/p2p', RouteGroup.app, 'Send / request cash, crypto or stocks to @username', gated: true),
  p2pdone('/p2pdone', RouteGroup.app, 'P2P success'),
  people('/people', RouteGroup.app, 'Choose recipient: Jarina users, cross-border, any bank', gated: true),
  payconfirm('/payconfirm', RouteGroup.app, 'Confirm payment (cross-border FX + corridor), note', gated: true),
  sending('/sending', RouteGroup.app, 'Payment in progress'),
  celebrate('/celebrate', RouteGroup.app, 'Payment sent celebration'),
  fiat('/fiat/:currency', RouteGroup.app, 'Currency wallet: transfer, receive, convert, history'),
  fiatadd('/fiatadd/:currency', RouteGroup.app, 'Add money (virtual account, MoMo, agent)'),
  convert('/convert', RouteGroup.app, 'Convert between currencies', gated: true),
  usdt('/usdt', RouteGroup.app, 'USDT wallet: networks, address book, whitelist'),
  withdraw('/withdraw', RouteGroup.app, 'Withdraw', gated: true),
  receive('/receive', RouteGroup.app, 'Receive: QR, @username, payment requests'),
  bill('/bill/:kind', RouteGroup.app, 'Airtime, data, cable TV, electricity', gated: true),
  review('/review', RouteGroup.app, 'Review before confirming', gated: true),
  authpin('/authpin', RouteGroup.app, 'Step-up: PIN / biometrics', gated: true),
  auth2fa('/auth2fa', RouteGroup.app, 'Step-up: 2FA code', gated: true),
  done('/done', RouteGroup.app, 'Success'),
  receipt('/receipt/:id', RouteGroup.app, 'Receipt with QR verification, cross-border flags'),

  // ── Settings & support ─────────────────────────────────────────────────
  account('/account', RouteGroup.app, 'Verification status, tier, 2FA, Face ID, change PIN'),
  language('/language', RouteGroup.app, 'App language'),
  chat('/chat', RouteGroup.app, 'Support chat in EN / HA / FR'),

  // ── Developer ──────────────────────────────────────────────────────────
  dev('/dev', RouteGroup.dev, 'Route index and session switches (non-prod only)');

  const AppRoute(this.path, this.group, this.spec, {this.gated = false});

  final String path;
  final RouteGroup group;

  /// One-line spec from SCREENS.md, shown on placeholder screens.
  final String spec;

  /// Needs 2FA on. Ported from the prototype's `GATED` list.
  final bool gated;

  /// Sub-path relative to its parent (shell branches nest `transfer`/`activity`).
  String get subPath => path.split('/').last;

  /// Default arguments so the dev index can open parameterised routes.
  Map<String, String> get sampleParams => switch (this) {
    asset => {'id': 'MTNN'},
    qcoin => {'coin': 'USDT'},
    fiat || fiatadd => {'currency': 'GHS'},
    bill => {'kind': 'electricity'},
    receipt => {'id': '260911522889869'},
    _ => const {},
  };

  static AppRoute? byName(String? name) => AppRoute.values.where((r) => r.name == name).firstOrNull;
}

enum RouteGroup { preAuth, kyc, tab, app, dev }
