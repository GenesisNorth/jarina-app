import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

@immutable
class PersonalDetails {
  const PersonalDetails({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    this.middleName,
  });

  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String email;
}

@immutable
class HomeAddress {
  const HomeAddress({
    required this.countryIso,
    required this.region,
    required this.city,
    required this.street,
    required this.occupation,
  });

  final String countryIso;
  final String region;
  final String city;
  final String street;
  final String occupation;
}

@immutable
class TotpSetup {
  const TotpSetup({required this.secret, required this.provisioningUri, required this.backupCodes});

  final String secret;
  final Uri provisioningUri;
  final List<String> backupCodes;
}

final class IdNotVerifiedFailure extends Failure {
  const IdNotVerifiedFailure() : super('Identity could not be verified');
}

final class UsernameTakenFailure extends Failure {
  const UsernameTakenFailure() : super('Username taken');
}

/// KYC steps 5–12. Each call is idempotent so a retry after a timeout is safe.
abstract interface class KycRepository {
  Future<Result<void>> submitPersonalDetails(PersonalDetails details);

  /// `true` when free. Cheap; called while the user types (debounced).
  Future<Result<bool>> isUsernameAvailable(String handle);

  Future<Result<void>> claimUsername(String handle);

  Future<Result<void>> verifyIdentity(IdType type, String number);

  /// Liveness is captured by the vendor SDK; this submits its session id.
  Future<Result<void>> submitLiveness(String vendorSessionId);

  Future<Result<void>> submitAddress(HomeAddress address);

  /// The PIN is sent once over TLS and hashed server-side. Never stored on device.
  Future<Result<void>> setPin(String pin);

  Future<Result<TotpSetup>> startTotpSetup();

  Future<Result<void>> confirmTotp(String code);
}
