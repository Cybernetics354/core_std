/// Utility functions for async operations and value mapping.
///
/// Includes helpers for wrapping async functions, mapping values with fallback,
/// and managing deferred execution for cleanup or teardown.
library;

import 'package:core_std/src/async_call.dart';
import 'package:core_std/src/defer.dart';

/// Wraps an asynchronous function in an [AsyncCall].
///
/// Example:
/// ```dart
/// final call = runAsync(() async => await someAsyncFunction());
/// final result = await call.exec();
/// ```
AsyncCall<T> runAsync<T>(Future<T> Function() asyncFunction) {
  return AsyncCall<T>(asyncFunction);
}

/// Returns the value from [map] for the given [value], or [fallback] if not found.
///
/// Example:
/// ```dart
/// final result = switchMap('a', {'a': 1, 'b': 2}, fallback: 0); // result == 1
/// final missing = switchMap('c', {'a': 1, 'b': 2}, fallback: 0); // missing == 0
/// ```
V switchMap<K, V>(K value, Map<K, V> map, {required V fallback}) {
  return map[value] ?? fallback;
}

/// Runs [fn] with a [DeferRegistry] and ensures all registered deferred functions are executed after [fn] completes.
///
/// This is useful for resource cleanup or teardown logic, similar to Go's `defer`.
///
/// Example:
/// ```dart
/// withDefer((defer) {
///   defer.register(() => print('cleanup'));
///   // ... do work ...
/// });
/// // 'cleanup' is printed after the function completes
/// ```
T withDefer<T>(T Function(DeferRegistry defer) fn) {
  final registry = DeferRegistry();
  try {
    return fn(registry);
  } finally {
    registry.execAll();
  }
}
