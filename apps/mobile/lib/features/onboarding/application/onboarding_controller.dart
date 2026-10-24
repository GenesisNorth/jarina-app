import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarina/core/providers.dart';
import 'package:jarina/core/seed/country.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Pre-auth onboarding state: steps 1–4 and the login flow.
@immutable
class OnboardingState {
  const OnboardingState({this.countryIso, this.challenge, this.loginTicket});

  final String? countryIso;
  final OtpChallenge? challenge;

  /// Set after password login on a new device; consumed by the 2FA screen.
  final String? loginTicket;

  OnboardingState copyWith({String? countryIso, OtpChallenge? challenge, String? loginTicket}) => OnboardingState(
    countryIso: countryIso ?? this.countryIso,
    challenge: challenge ?? this.challenge,
    loginTicket: loginTicket ?? this.loginTicket,
  );
}

@Riverpod(keepAlive: true)
class Onboarding extends _$Onboarding {
  static const _countryKey = 'onboarding.country';

  @override
  OnboardingState build() => OnboardingState(countryIso: ref.watch(sharedPreferencesProvider).getString(_countryKey));

  Future<void> setCountry(String iso) async {
    state = OnboardingState(countryIso: iso);
    await ref.read(sharedPreferencesProvider).setString(_countryKey, iso);
  }

  // Methods read as actions at call sites (`.setChallenge(c)`).
  // ignore: use_setters_to_change_properties
  void setChallenge(OtpChallenge c) => state = state.copyWith(challenge: c);

  // ignore: use_setters_to_change_properties, same as above.
  void setLoginTicket(String t) => state = state.copyWith(loginTicket: t);
}

/// The chosen country, defaulting to Nigeria (largest market) when unset.
@riverpod
Future<Country> selectedCountry(Ref ref) async {
  final all = await ref.watch(countriesProvider.future);
  final iso = ref.watch(onboardingProvider.select((s) => s.countryIso));
  return all.firstWhere((c) => c.iso == iso, orElse: () => all.first);
}

/// Non-sensitive KYC answers, saved so a half-finished sign-up resumes after a
/// restart. ID numbers and the PIN are never persisted on the device.
@immutable
class KycDraft {
  const KycDraft({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.dob = '',
    this.email = '',
    this.username = '',
    this.region,
    this.city = '',
    this.street = '',
    this.occupation,
  });

  factory KycDraft.fromJson(Map<String, dynamic> j) => KycDraft(
    firstName: j['firstName'] as String? ?? '',
    middleName: j['middleName'] as String? ?? '',
    lastName: j['lastName'] as String? ?? '',
    dob: j['dob'] as String? ?? '',
    email: j['email'] as String? ?? '',
    username: j['username'] as String? ?? '',
    region: j['region'] as String?,
    city: j['city'] as String? ?? '',
    street: j['street'] as String? ?? '',
    occupation: j['occupation'] as String?,
  );

  final String firstName;
  final String middleName;
  final String lastName;
  final String dob;
  final String email;
  final String username;
  final String? region;
  final String city;
  final String street;
  final String? occupation;

  String get displayName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'dob': dob,
    'email': email,
    'username': username,
    'region': region,
    'city': city,
    'street': street,
    'occupation': occupation,
  };

  KycDraft copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? dob,
    String? email,
    String? username,
    String? region,
    String? city,
    String? street,
    String? occupation,
  }) => KycDraft(
    firstName: firstName ?? this.firstName,
    middleName: middleName ?? this.middleName,
    lastName: lastName ?? this.lastName,
    dob: dob ?? this.dob,
    email: email ?? this.email,
    username: username ?? this.username,
    region: region ?? this.region,
    city: city ?? this.city,
    street: street ?? this.street,
    occupation: occupation ?? this.occupation,
  );
}

@Riverpod(keepAlive: true)
class KycDraftStore extends _$KycDraftStore {
  static const _key = 'kyc.draft';

  @override
  KycDraft build() {
    final raw = ref.watch(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const KycDraft();
    try {
      return KycDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return const KycDraft();
    }
  }

  Future<void> save(KycDraft draft) async {
    state = draft;
    await ref.read(sharedPreferencesProvider).setString(_key, jsonEncode(draft.toJson()));
  }

  /// Called once onboarding completes; the server is now the source of truth.
  Future<void> clear() async {
    state = const KycDraft();
    await ref.read(sharedPreferencesProvider).remove(_key);
  }
}
