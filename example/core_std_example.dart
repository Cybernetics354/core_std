import 'package:core_std/core_std.dart';

Future<void> main() async {
  // Example usage of AsyncCall
  final call = AsyncCall(
    () async => await Future.delayed(
      Duration(milliseconds: 500),
      () => 'Hello, World!',
    ),
  );

  // Basic exec
  final result = await call.exec();
  print('AsyncCall.exec: $result'); // Should print 'Hello, World!'

  // withFallback
  final fallbackResult =
      await AsyncCall<String>(
        () async => throw Exception('fail'),
      ).withFallback('Fallback Value').exec();
  print(
    'AsyncCall.withFallback: $fallbackResult',
  ); // Should print 'Fallback Value'

  // withError
  final (error, value) =
      await AsyncCall<int>(() async => throw 'error').withError().exec();
  print(
    'AsyncCall.withError: error=$error, value=$value',
  ); // Should print error

  // withTimeout
  try {
    await AsyncCall(() async {
      await Future.delayed(Duration(seconds: 2));
      return 'timeout test';
    }).withTimeout(Duration(milliseconds: 500)).exec();
  } catch (e) {
    print('AsyncCall.withTimeout: $e'); // Should print TimeoutException
  }

  // withRetry
  int attempts = 0;
  final retryResult =
      await AsyncCall(() async {
        if (attempts < 2) {
          attempts++;
          throw Exception('fail');
        }
        return 'Retried!';
      }).withRetry(3, delay: Duration(milliseconds: 100)).exec();
  print('AsyncCall.withRetry: $retryResult'); // Should print 'Retried!'

  // retryUntilSuccess
  int untilSuccess = 0;
  final untilSuccessResult =
      await AsyncCall(() async {
        if (untilSuccess < 1) {
          untilSuccess++;
          throw Exception('fail');
        }
        return 'Finally!';
      }).retryUntilSuccess(delay: Duration(milliseconds: 100)).exec();
  print(
    'AsyncCall.retryUntilSuccess: $untilSuccessResult',
  ); // Should print 'Finally!'

  // FutureExtension: withError
  final (futError, futValue) =
      await Future<int>.error('future error').withError();
  print(
    'Future.withError: error=$futError, value=$futValue',
  ); // Should print error

  // FutureExtension: withFallback
  final futFallback = await Future<int>.error('fail').withFallback(123);
  print('Future.withFallback: $futFallback'); // Should print 123

  // FutureExtension: thenWithCatch
  final processed = await Future.value(5).thenWithCatch((err, val) => val! * 2);
  print('Future.thenWithCatch: $processed'); // Should print 10

  // switchMap utility
  final mapped = switchMap('b', {'a': 1, 'b': 2}, fallback: 0);
  print('switchMap: $mapped'); // Should print 2

  // withDefer utility
  final log = <String>[];
  withDefer((defer) {
    defer.register(() => log.add('cleanup'));
    log.add('work');
  });
  print('withDefer: $log'); // Should print ['work', 'cleanup']

  // DeferRegistry direct usage
  final registry = DeferRegistry();
  registry.register(() => print('Deferred 1'));
  registry.registerKey('custom', () => print('Deferred 2'));
  registry.execAll(); // Should print both deferred messages
}
