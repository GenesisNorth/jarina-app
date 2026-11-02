enum Flavor { dev, staging, prod }

/// Build-time configuration, chosen by the `main_<flavor>.dart` entry point.
class Env {
  const Env({
    required this.flavor,
    required this.apiBaseUrl,
    required this.useFakeData,
    this.liveApi = false,
    this.liveWallet = false,
  });

  static const dev = Env(flavor: Flavor.dev, apiBaseUrl: _localApi, useFakeData: true);

  /// Dev build whose features with a finished API (sign-up, login, KYC
  /// details, PIN, 2FA, profile, devices, markets) use a local server
  /// (`make dev` in jarina_backend); ID checks and money movements are
  /// still fake.
  static const local = Env(
    flavor: Flavor.dev,
    apiBaseUrl: _localApi,
    useFakeData: true,
    liveApi: true,
    // Set by --dart-define at build time; the analyzer only sees the default.
    // ignore: avoid_redundant_argument_values
    liveWallet: _liveWallet,
  );
  static const staging = Env(flavor: Flavor.staging, apiBaseUrl: 'https://api.staging.jarina.app', useFakeData: true);
  static const prod = Env(flavor: Flavor.prod, apiBaseUrl: 'https://api.jarina.app', useFakeData: false);

  /// The iOS simulator reaches the Mac as localhost; an Android emulator
  /// needs `--dart-define=JARINA_API_URL=http://10.0.2.2:3100`.
  static const _liveWallet = bool.fromEnvironment('JARINA_LIVE_WALLET');
  static const _localApi = String.fromEnvironment('JARINA_API_URL', defaultValue: 'http://localhost:3100');

  final Flavor flavor;
  final String apiBaseUrl;

  /// Use `Fake*Repository` implementations seeded from the prototype data.
  /// Stays true outside prod until the backend phase lands.
  final bool useFakeData;

  /// Features whose API exists use it, even while other data is fake.
  final bool liveApi;

  /// Account features (and their demo codes) come from the in-memory fake.
  bool get fakeAuth => useFakeData && !liveApi;

  /// Catalogue, prices and charts come from the in-memory fake.
  bool get fakeMarkets => useFakeData && !liveApi;

  /// Local builds opt in to the real wallet (balances, funding account,
  /// deposits, activity) with `--dart-define=JARINA_LIVE_WALLET=true`.
  /// Off by default there because trading is still fake: with it on, demo
  /// trades don't change the real balances.
  final bool liveWallet;

  bool get fakeWallet => useFakeData && !(liveApi && liveWallet);

  bool get showDevTools => flavor != Flavor.prod;
}
