enum Flavor { dev, staging, prod }

/// Build-time configuration, chosen by the `main_<flavor>.dart` entry point.
class Env {
  const Env({required this.flavor, required this.apiBaseUrl, required this.useFakeData});

  static const dev = Env(flavor: Flavor.dev, apiBaseUrl: 'http://localhost:8080', useFakeData: true);
  static const staging = Env(flavor: Flavor.staging, apiBaseUrl: 'https://api.staging.jarina.app', useFakeData: true);
  static const prod = Env(flavor: Flavor.prod, apiBaseUrl: 'https://api.jarina.app', useFakeData: false);

  final Flavor flavor;
  final String apiBaseUrl;

  /// Use `Fake*Repository` implementations seeded from the prototype data.
  /// Stays true outside prod until the backend phase lands.
  final bool useFakeData;

  bool get showDevTools => flavor != Flavor.prod;
}
