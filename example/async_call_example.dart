import 'package:core_std/src/async_call.dart';

Future<void> main() async {
  // Example: Basic usage of AsyncCall
  final call = AsyncCall(() async => 'Hello, AsyncCall!');
  final result = await call.exec();
  print('AsyncCall.exec: $result'); // Should print 'Hello, AsyncCall!'

  // Example: withFallback
  final fallbackResult = await AsyncCall<String>(() async => throw Exception('fail'))
      .withFallback('Fallback Value')
      .exec();
  print('AsyncCall.withFallback: $fallbackResult'); // Should print 'Fallback Value'

  // Example: withError
  final (error, value) = await AsyncCall<int>(() async => throw 'error')
      .withError()
      .exec();
  print('AsyncCall.withError: error=$error, value=$value'); // Should print error

  // Example: withTimeout
  try {
    await AsyncCall(() async {
      await Future.delayed(Duration(seconds: 2));
      return 'timeout test';
    }).withTimeout(Duration(milliseconds: 500)).exec();
  } catch (e) {
    print('AsyncCall.withTimeout: $e'); // Should print TimeoutException
  }

  // Example: withRetry
  int attempts = 0;
  final retryResult = await AsyncCall(() async {
    if (attempts < 2) {
      attempts++;
      throw Exception('fail');
    }
    return 'Retried!';
  }).withRetry(3, delay: Duration(milliseconds: 100)).exec();
  print('AsyncCall.withRetry: $retryResult'); // Should print 'Retried!'

  // Example: retryUntilSuccess
  int untilSuccess = 0;
  final untilSuccessResult = await AsyncCall(() async {
    if (untilSuccess < 1) {
      untilSuccess++;
      throw Exception('fail');
    }
    return 'Finally!';
  }).retryUntilSuccess(delay: Duration(milliseconds: 100)).exec();
  print('AsyncCall.retryUntilSuccess: $untilSuccessResult'); // Should print 'Finally!'
}