import 'package:jarina/core/api/api_client.dart';
import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/features/security/domain/security_repository.dart';
import 'package:jarina_core/jarina_core.dart';

/// The API's error codes (`docs/API.md`) as the failures screens know how to show.
Failure apiFailure(Failure f) => switch (f) {
  ApiFailure(code: 'wrong_code', :final details) => WrongCodeFailure(attemptsLeft: details['attemptsLeft'] as int?),
  ApiFailure(code: 'code_expired') => const CodeExpiredFailure(),
  ApiFailure(code: 'user_not_found') => const NoAccountFailure(),
  ApiFailure(code: 'rate_limited', :final details) => RateLimitedFailure(
    Duration(seconds: details['retryAfterSeconds'] as int? ?? 60),
  ),
  ApiFailure(code: 'wrong_pin', :final details) => WrongPinFailure(details['attemptsLeft'] as int? ?? 0),
  ApiFailure(code: 'pin_locked') => const PinLockedFailure(),
  ApiFailure(code: 'step_up_required', :final details) => StepUpRequiredFailure(
    details['level'] == 'pin' ? StepUpLevel.pin : StepUpLevel.pinAnd2fa,
  ),
  ApiFailure(code: 'username_taken') => const UsernameTakenFailure(),
  ApiFailure(code: 'validation_failed', :final message, :final details) => ValidationFailure(
    message,
    field: details['field'] as String?,
  ),
  _ => f,
};

/// Maps a JSON object response, turning errors into app failures.
Result<T> mapJson<T>(Result<Object?> r, T Function(Map<String, Object?> json) parse) => switch (r) {
  Ok(value: final Map<String, Object?> json) => Ok(parse(json)),
  Ok() => const Err(UnknownFailure('Unexpected response')),
  Err(:final failure) => Err(apiFailure(failure)),
};

/// For calls that answer 204.
Result<void> mapVoid(Result<Object?> r) => switch (r) {
  Ok() => const Ok(null),
  Err(:final failure) => Err(apiFailure(failure)),
};
