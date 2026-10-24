import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum OtpChannel { whatsapp, sms }

/// A pending phone verification.
@immutable
class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.phoneE164,
    required this.channel,
    required this.resendAvailableAt,
    required this.expiresAt,
  });

  final String id;
  final String phoneE164;
  final OtpChannel channel;
  final DateTime resendAvailableAt;
  final DateTime expiresAt;
}

/// Tokens plus the account flags the router needs.
@immutable
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.onboarded,
    required this.twofaEnabled,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final bool onboarded;
  final bool twofaEnabled;
}

/// Password accepted on a new device; a 2FA code is still needed.
@immutable
class LoginChallenge {
  const LoginChallenge({required this.ticket});
  final String ticket;
}

/// Failure-specific to auth flows.
final class WrongCodeFailure extends ValidationFailure {
  const WrongCodeFailure({this.attemptsLeft}) : super('Wrong code');
  final int? attemptsLeft;
}

final class RateLimitedFailure extends Failure {
  const RateLimitedFailure(this.retryAfter) : super('Rate limited');
  final Duration retryAfter;
}

final class CodeExpiredFailure extends Failure {
  const CodeExpiredFailure() : super('Code expired');
}

final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid credentials');
}

abstract interface class AuthRepository {
  /// Sends a one-time code. Server enforces resend cooldown and daily caps.
  Future<Result<OtpChallenge>> sendOtp({required String phoneE164, required OtpChannel channel});

  Future<Result<AuthSession>> verifyOtp({required String challengeId, required String code});

  Future<Result<LoginChallenge>> login({required String phoneE164, required String password});

  /// [code] is a TOTP code or, when [isBackupCode], a one-time backup code.
  Future<Result<AuthSession>> completeLogin({required String ticket, required String code, bool isBackupCode = false});

  Future<void> logout();
}
