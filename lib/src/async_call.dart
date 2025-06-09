/// Provides a wrapper for asynchronous function calls with utility extensions
/// for error handling, fallback values, timeouts, and retry logic.
///
/// Example usage:
/// ```dart
/// final call = AsyncCall(() async => await someAsyncFunction());
/// final result = await call.withFallback(defaultValue).exec();
/// ```
library;

import 'dart:async';

/// Type definition for an asynchronous function returning [Future<T>].
typedef AsyncCallType<T> = Future<T> Function();

/// A wrapper class for an asynchronous call of type [T].
///
/// Use [exec] to execute the wrapped asynchronous function.
class AsyncCall<T> {
  /// The asynchronous callback to execute.
  final AsyncCallType<T> callback;

  /// Creates an [AsyncCall] with the given [callback].
  const AsyncCall(this.callback);

  /// Executes the asynchronous callback and returns its result.
  Future<T> exec() async {
    return await callback();
  }
}

/// Extension methods for [AsyncCall] providing error handling,
/// fallback, timeout, and retry utilities.
extension AsyncCallExtension<T> on AsyncCall<T> {
  /// Returns a new [AsyncCall] that wraps the result in a tuple of (error, result).
  ///
  /// If the call succeeds, [error] is `null` and [result] contains the value.
  /// If the call fails, [error] contains the error and [result] is `null`.
  AsyncCall<(dynamic error, T? result)> withError() {
    return AsyncCall<(dynamic error, T? result)>(() async {
      try {
        final result = await exec();
        return (null, result);
      } catch (error) {
        return (error, null);
      }
    });
  }

  /// Returns a new [AsyncCall] that returns [defaultValue] if the call fails.
  ///
  /// If the call succeeds, the result is returned as normal.
  /// If an error occurs, [defaultValue] is returned instead.
  AsyncCall<T> withFallback(T defaultValue) {
    return AsyncCall<T>(() async {
      try {
        return await exec();
      } catch (_) {
        return defaultValue;
      }
    });
  }

  /// Returns a new [AsyncCall] that throws a [TimeoutException] if the call
  /// does not complete within [duration].
  AsyncCall<T> withTimeout(Duration duration) {
    return AsyncCall<T>(() async {
      return await exec().timeout(
        duration,
        onTimeout: () {
          throw TimeoutException('Operation timed out after $duration');
        },
      );
    });
  }

  /// Returns a new [AsyncCall] that retries the call up to [retries] times
  /// with an optional [delay] between attempts.
  ///
  /// Optionally, provide [shouldRetry] to control which errors should trigger a retry.
  AsyncCall<T> withRetry(
    int retries, {
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) {
    return AsyncCall<T>(() async {
      int attempt = 0;
      while (true) {
        try {
          return await exec();
        } catch (e) {
          if (attempt >= retries) rethrow;
          if (shouldRetry != null && !shouldRetry(e)) rethrow;

          attempt++;
          await Future.delayed(delay);
        }
      }
    });
  }

  /// Returns a new [AsyncCall] that retries indefinitely until success,
  /// with an optional [delay] between attempts.
  ///
  /// Optionally, provide [shouldRetry] to control which errors should trigger a retry.
  AsyncCall<T> retryUntilSuccess({
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) {
    return AsyncCall<T>(() async {
      while (true) {
        try {
          return await exec();
        } catch (error) {
          if (shouldRetry != null && !shouldRetry(error)) rethrow;
          await Future.delayed(delay);
        }
      }
    });
  }
}
