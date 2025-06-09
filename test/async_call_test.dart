import 'dart:async';
import 'package:test/test.dart';
import 'package:core_std/src/async_call.dart';

void main() {
  group('AsyncCall', () {
    test('exec returns result', () async {
      final result = await AsyncCall(() async => 42).exec();
      expect(result, 42);
    });
  });

  group('AsyncCallExtension', () {
    test('withError returns result on success', () async {
      final (error, result) = await AsyncCall(() async => 7).withError().exec();
      expect(error, isNull);
      expect(result, 7);
    });

    test('withError returns error on failure', () async {
      final (error, result) =
          await AsyncCall(
            () async => throw Exception('fail'),
          ).withError().exec();

      expect(error, isNotNull);
      expect(result, isNull);
    });

    test('withFallback returns result on success', () async {
      final result =
          await AsyncCall(() async => 'ok').withFallback('fallback').exec();

      expect(result, 'ok');
    });

    test('withFallback returns fallback on error', () async {
      final result =
          await AsyncCall<String>(
            () async => throw Exception('fail'),
          ).withFallback("fallback").exec();

      expect(result, 'fallback');
    });

    test('withTimeout returns result if within duration', () async {
      final result =
          await AsyncCall(() async {
            await Future.delayed(Duration(milliseconds: 50));
            return 1;
          }).withTimeout(Duration(seconds: 1)).exec();

      expect(result, 1);
    });

    test('withTimeout throws TimeoutException if exceeded', () async {
      final call = AsyncCall<int>(() async {
        await Future.delayed(Duration(milliseconds: 200));
        return 2;
      }).withTimeout(Duration(milliseconds: 50));

      expect(call.exec(), throwsA(isA<TimeoutException>()));
    });

    test('withRetry succeeds after retries', () async {
      int count = 0;
      final result =
          await AsyncCall(() async {
            if (count < 2) {
              count++;
              throw Exception('fail');
            }
            return 99;
          }).withRetry(3, delay: Duration(milliseconds: 10)).exec();

      expect(result, 99);
      expect(count, 2);
    });

    test('withRetry throws after max retries', () async {
      int count = 0;
      final call = AsyncCall(() async {
        count++;
        throw Exception('fail');
      }).withRetry(2, delay: Duration(milliseconds: 10));

      expect(call.exec(), throwsException);
      expect(count, lessThanOrEqualTo(3));
    });

    test('withRetry respects shouldRetry', () async {
      int count = 0;
      final call = AsyncCall(() async {
        count++;
        throw 'fatal';
      }).withRetry(2, shouldRetry: (e) => e != 'fatal');

      expect(call.exec(), throwsA('fatal'));
      expect(count, 1);
    });

    test('retryUntilSuccess eventually succeeds', () async {
      int count = 0;
      final result =
          await AsyncCall(() async {
            if (count < 2) {
              count++;
              throw Exception('fail');
            }
            return 123;
          }).retryUntilSuccess(delay: Duration(milliseconds: 10)).exec();

      expect(result, 123);
      expect(count, 2);
    });

    test('retryUntilSuccess stops if shouldRetry returns false', () async {
      int count = 0;
      final call = AsyncCall(() async {
        count++;
        throw 'fatal';
      }).retryUntilSuccess(shouldRetry: (e) => e != 'fatal');

      expect(call.exec(), throwsA('fatal'));
      expect(count, 1);
    });
  });
}
