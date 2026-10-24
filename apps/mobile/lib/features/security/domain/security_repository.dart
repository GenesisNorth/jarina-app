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
}
