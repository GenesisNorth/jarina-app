import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({required this.firstName, required this.lastName, required this.username, required this.tier});

  final String firstName;
  final String lastName;
  final String username;

  /// KYC tier (1–3); limits depend on it.
  final int tier;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();
}

abstract interface class ProfileRepository {
  Future<UserProfile> me();
}
