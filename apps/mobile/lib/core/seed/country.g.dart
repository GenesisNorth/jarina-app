// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Countries from the prototype seed. In the backend phase this comes from
/// `/config/countries` so new markets can launch without an app release.

@ProviderFor(countries)
final countriesProvider = CountriesProvider._();

/// Countries from the prototype seed. In the backend phase this comes from
/// `/config/countries` so new markets can launch without an app release.

final class CountriesProvider
    extends $FunctionalProvider<AsyncValue<List<Country>>, List<Country>, FutureOr<List<Country>>>
    with $FutureModifier<List<Country>>, $FutureProvider<List<Country>> {
  /// Countries from the prototype seed. In the backend phase this comes from
  /// `/config/countries` so new markets can launch without an app release.
  CountriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'countriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$countriesHash();

  @$internal
  @override
  $FutureProviderElement<List<Country>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Country>> create(Ref ref) {
    return countries(ref);
  }
}

String _$countriesHash() => r'ca6d204356d9a6463e706858df88287a13948c2d';
