/// Expected failures the UI knows how to present. Features add their own
/// subclasses (e.g. `WrongCodeFailure`) next to their repositories.
abstract class Failure {
  const Failure(this.message);

  /// Developer-facing detail. User-facing copy comes from l10n per type.
  final String message;

  @override
  String toString() => 'Failure: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network unavailable']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});
  final String? field;
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);
}

enum StepUpLevel { pin, pinAnd2fa }

/// The action needs a fresh PIN (and maybe 2FA) token before it can proceed.
final class StepUpRequiredFailure extends Failure {
  const StepUpRequiredFailure(this.level) : super('Step-up required');
  final StepUpLevel level;
}

/// The account has 2FA off and the action is gated.
final class AccountLimitedFailure extends Failure {
  const AccountLimitedFailure() : super('Account limited until 2FA is on');
}

final class InsufficientFundsFailure extends Failure {
  const InsufficientFundsFailure([super.message = 'Insufficient balance']);
}

final class QuoteExpiredFailure extends Failure {
  const QuoteExpiredFailure() : super('Quote expired');
}

final class LimitExceededFailure extends Failure {
  const LimitExceededFailure(super.message);
}

final class MarketClosedFailure extends Failure {
  const MarketClosedFailure() : super('Market closed');
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [this.error]);
  final Object? error;
}
