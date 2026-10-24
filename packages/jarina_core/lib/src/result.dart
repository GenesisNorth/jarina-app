import 'package:jarina_core/src/failure.dart';

/// Outcome of an operation that can fail in an expected way.
///
/// Repositories return `Result` instead of throwing so every screen is forced
/// to handle the failure path (insufficient funds, expired quote, step-up…).
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  R when<R>({required R Function(T value) ok, required R Function(Failure failure) err}) => switch (this) {
    Ok(:final value) => ok(value),
    Err(:final failure) => err(failure),
  };

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  Result<R> map<R>(R Function(T value) f) => switch (this) {
    Ok(:final value) => Ok(f(value)),
    Err(:final failure) => Err(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
