import 'package:flutter/foundation.dart';
import 'package:jarina_core/jarina_core.dart';

enum OtpChannel { whatsapp, sms }

/// Why the code was sent: creating an account, or logging in to an existing one.
enum OtpPurpose { signup, login }

/// A pending phone verification.
@immutable
class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.phoneE164,
    required this.channel,
    required this.resendAvailableAt,
    required this.expiresAt,
    this.purpose = OtpPurpose.signup,
  });

  final String id;
  final String phoneE164;
  final OtpChannel channel;
  final OtpPurpose purpose;
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

/// Result of a correct OTP.
sealed class OtpOutcome {
  const OtpOutcome();
}

/// New account created, or login on a device that needs no further check.
final class SignedIn extends OtpOutcome {
  const SignedIn(this.session);
  final AuthSession session;
}

/// Login with 2FA on: the authenticator (or a backup code) is still needed.
final class TwofaRequired extends OtpOutcome {
  const TwofaRequired(this.ticket);
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

abstract interface class AuthRepository {
  /// Sends a one-time code. Server enforces resend cooldown and daily caps.
  /// Login has no password: the WhatsApp code proves the phone, the
  /// authenticator proves the person (2FA is mandatory to transact).
  Future<Result<OtpChallenge>> sendOtp({
    required String phoneE164,
    required OtpChannel channel,
    OtpPurpose purpose = OtpPurpose.signup,
  });

  Future<Result<OtpOutcome>> verifyOtp({required String challengeId, required String code});

  /// [code] is a TOTP code or, when [isBackupCode], a one-time backup code.
  Future<Result<AuthSession>> completeLogin({required String ticket, required String code, bool isBackupCode = false});

  Future<void> logout();
}
