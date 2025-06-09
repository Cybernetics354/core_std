<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# core_std

A collection of utility APIs for Dart to simplify asynchronous programming, error handling, value mapping, and resource cleanup.  
This package provides wrappers and extensions for common async patterns, making your code more robust and expressive.

---

## Features

- **AsyncCall**: Wraps async functions with utilities for error handling, fallback values, timeouts, and retry logic.
- **FutureExtension**: Adds methods to `Future` for error handling, fallback, and unified result/error processing.
- **switchMap**: Maps a value to another using a map, with a fallback if not found.
- **withDefer & DeferRegistry**: Manage deferred execution for cleanup or teardown, similar to Go's `defer`.

---

## Getting started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  core_std: ^<latest_version>
```

Import in your Dart code:

```dart
import 'package:core_std/core_std.dart';
```

---

## Usage

### AsyncCall

```dart
final call = AsyncCall(() async => await someAsyncFunction());

// Basic execution
final result = await call.exec();

// With fallback value on error
final safeResult = await call.withFallback('default').exec();

// With error tuple
final (error, value) = await call.withError().exec();

// With timeout
try {
  await call.withTimeout(Duration(seconds: 1)).exec();
} catch (e) {
  print('Timeout: $e');
}

// With retry logic
int attempts = 0;
final retryResult = await AsyncCall(() async {
  if (attempts < 2) {
    attempts++;
    throw Exception('fail');
  }
  return 'Retried!';
}).withRetry(3, delay: Duration(milliseconds: 100)).exec();
```

### FutureExtension

```dart
final future = Future.value(42);

// Wrap result in (error, value) tuple
final (error, value) = await future.withError();

// Provide fallback on error
final safeValue = await Future<int>.error('fail').withFallback(123);

// Unified result/error processing
final processed = await future.thenWithCatch((error, value) {
  if (error != null) return -1;
  return value! * 2;
});
```

### switchMap

```dart
final map = {'a': 1, 'b': 2};
final result = switchMap('a', map, fallback: 0); // 1
final missing = switchMap('c', map, fallback: 0); // 0
```

### withDefer & DeferRegistry

```dart
// withDefer utility
final log = <String>[];
withDefer((defer) {
  defer.register(() => log.add('cleanup'));
  log.add('work');
});
// log == ['work', 'cleanup']

// Direct DeferRegistry usage
final registry = DeferRegistry();
registry.register(() => print('Deferred 1'));
registry.registerKey('custom', () => print('Deferred 2'));
registry.execAll(); // Executes all registered deferred functions
```

---

## Examples

See the [`/example`](./example) folder for more complete usage:

- [`async_call_example.dart`](./example/async_call_example.dart)
- [`future_extension_example.dart`](./example/future_extension_example.dart)
- [`utils_example.dart`](./example/utils_example.dart)

---

## Additional information

- [API Reference](https://pub.dev/documentation/core_std/latest/)
- Issues and contributions welcome via [GitHub](https://github.com/Cybernetics354/core_std).
- Licensed under the MIT License.

---
