import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.tier,
    this.phoneE164,
    this.email,
    this.custodyAccountId,
    this.dailyWithdrawalLimit,
  });

  final String firstName;
  final String lastName;
  final String username;

  /// KYC tier (1–3); limits depend on it.
  final int tier;
  final String? phoneE164;
  final String? email;

  /// The user's sub-account with the crypto custody partner.
  final String? custodyAccountId;
  final Money? dailyWithdrawalLimit;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();

  UserProfile copyWith({String? firstName, String? lastName, String? username}) => UserProfile(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    username: username ?? this.username,
    tier: tier,
    phoneE164: phoneE164,
    email: email,
    custodyAccountId: custodyAccountId,
    dailyWithdrawalLimit: dailyWithdrawalLimit,
  );
}

abstract interface class ProfileRepository {
  Future<UserProfile> me();
}
