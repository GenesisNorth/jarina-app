import 'package:jarina/features/auth/domain/auth_repository.dart';
import 'package:jarina/features/kyc/domain/kyc_repository.dart';
import 'package:jarina/l10n/gen/app_localizations.dart';
import 'package:jarina_core/jarina_core.dart';

/// User-facing copy for domain failures and validation errors.
extension FailureMessages on AppLocalizations {
  String failure(Failure f) => switch (f) {
    NetworkFailure() => errNetwork,
    WrongCodeFailure() => errWrongCode,
    CodeExpiredFailure() => errCodeExpired,
    RateLimitedFailure(:final retryAfter) =>
      retryAfter.inMinutes >= 1 ? errTooManyAttempts('${retryAfter.inMinutes}') : resendCodeIn(_mmss(retryAfter)),
    IdNotVerifiedFailure() => errIdNotVerified,
    UsernameTakenFailure() => errReserved,
    _ => errGeneric,
  };

  String field(FieldError e) => switch (e) {
    FieldError.required => errRequired,
    FieldError.tooShort => errTooShort,
    FieldError.tooLong => errTooLong,
    FieldError.invalidFormat => errInvalidFormat,
    FieldError.mustStartWithLetter => errUsernameStart,
    FieldError.reserved => errReserved,
    FieldError.underage => errUnderage,
    FieldError.invalidDate => errInvalidDate,
    FieldError.weakPin => errWeakPin,
    FieldError.mismatch => errPinMismatch,
  };

  String countryName(String iso) => switch (iso) {
    'NG' => countryNG,
    'NE' => countryNE,
    'GH' => countryGH,
    'CM' => countryCM,
    'BJ' => countryBJ,
    'TG' => countryTG,
    _ => iso,
  };
}

String _mmss(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// `0:28` style countdown.
String formatCountdown(Duration d) => _mmss(d.isNegative ? Duration.zero : d);
