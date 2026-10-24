import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'country.g.dart';

/// A country Jarina operates in (onboarding step 1).
@immutable
class Country {
  const Country({
    required this.iso,
    required this.dialCode,
    required this.sample,
    required this.nationalLength,
    required this.languages,
    required this.regionWord,
    required this.regions,
  });

  factory Country.fromJson(Map<String, dynamic> j) => Country(
    iso: j['iso'] as String,
    dialCode: j['code'] as String,
    sample: j['sample'] as String,
    nationalLength: j['len'] as int,
    languages: (j['langs'] as List).cast<String>(),
    regionWord: RegionWord.values.byName((j['regionWord'] as String).toLowerCase()),
    regions: (j['regions'] as List).cast<String>(),
  );

  final String iso;

  /// `+234`
  final String dialCode;

  /// Placeholder in local format, e.g. `0801 234 5678`.
  final String sample;

  /// Digits in a local number including any trunk zero (Nigeria: 11).
  final int nationalLength;

  /// Language codes offered in this country, in display order.
  final List<String> languages;
  final RegionWord regionWord;
  final List<String> regions;

  bool get isNigeria => iso == 'NG';

  @override
  bool operator ==(Object other) => other is Country && other.iso == iso;

  @override
  int get hashCode => iso.hashCode;
}

enum RegionWord { state, region, department }

/// Countries from the prototype seed. In the backend phase this comes from
/// `/config/countries` so new markets can launch without an app release.
@Riverpod(keepAlive: true)
Future<List<Country>> countries(Ref ref) async {
  final raw = await rootBundle.loadString('assets/seed/countries.json');
  return (jsonDecode(raw) as List).map((e) => Country.fromJson(e as Map<String, dynamic>)).toList();
}
