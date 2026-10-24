import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

final class WrongPinFailure extends Failure {
  const WrongPinFailure(this.attemptsLeft) : super('Wrong PIN');
  final int attemptsLeft;
}

final class PinLockedFailure extends Failure {
  const PinLockedFailure() : super('PIN locked');
}

/// Step-up checks before money moves.
abstract interface class SecurityRepository {
  /// Returns a short-lived token the money-moving call must present.
  /// The server counts wrong attempts and locks the PIN after 5.
  Future<Result<String>> verifyPin(String pin);

  /// Second factor for withdrawals, sells to bank and cross-border sends.
  Future<Result<String>> verify2fa(String code);

  /// Checks [currentPin] (counting wrong attempts) and sets [newPin].
  Future<Result<void>> changePin({required String currentPin, required String newPin});

  /// Unused one-time backup codes.
  Future<int> backupCodesLeft();

  /// Replaces all backup codes. Needs a fresh 2FA token.
  Future<Result<List<String>>> regenerateBackupCodes({required String twofaToken});

  Future<List<TrustedDevice>> trustedDevices();

  /// Signs a device out; it will need WhatsApp + 2FA to log in again.
  Future<Result<void>> removeDevice(String id, {required String pinToken});
}

@immutable
class TrustedDevice {
  const TrustedDevice({required this.id, required this.name, required this.lastSeen, this.current = false});

  final String id;
  final String name;
  final DateTime lastSeen;

  /// This phone. It can't be removed from here; log out instead.
  final bool current;
}
