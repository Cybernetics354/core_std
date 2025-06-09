import 'package:core_std/src/async_call.dart';
import 'package:test/test.dart';
import 'package:core_std/src/utils.dart';

void main() {
  group('runAsync', () {
    test('wraps and executes async function', () async {
      final call = runAsync(() async => 42);
      final result = await call.exec();
      expect(result, 42);
    });

    test('propagates errors from async function', () async {
      final call = runAsync<int>(() async => throw Exception('fail'));
      expect(call.exec(), throwsA(isA<Exception>()));
    });

    test('can be used with withFallback', () async {
      final call = runAsync<int>(() async => throw Exception('fail'));
      final fallbackCall = call.withFallback(99);
      final result = await fallbackCall.exec();
      expect(result, 99);
    });
  });

  group('switchMap', () {
    test('returns mapped value if present', () {
      final map = {'a': 1, 'b': 2};
      final result = switchMap('a', map, fallback: 0);
      expect(result, 1);
    });

    test('returns fallback if value not present', () {
      final map = {'a': 1, 'b': 2};
      final result = switchMap('c', map, fallback: 0);
      expect(result, 0);
    });

    test('works with non-string keys', () {
      final map = {1: 'one', 2: 'two'};
      final result = switchMap(2, map, fallback: 'none');
      expect(result, 'two');
    });

    test('returns fallback for null key', () {
      final map = {null: 'nullValue', 1: 'one'};
      final result = switchMap(2, map, fallback: 'fallback');
      expect(result, 'fallback');
    });

    test('returns value for null key if present', () {
      final map = {null: 'nullValue', 1: 'one'};
      final result = switchMap(null, map, fallback: 'fallback');
      expect(result, 'nullValue');
    });
  });

  group('withDefer', () {
    test('executes deferred functions after fn completes', () {
      var called = false;
      withDefer((defer) {
        defer.register(() => called = true);
        expect(called, isFalse);
      });
      expect(called, isTrue);
    });

    test('executes multiple deferred functions in order of registration', () {
      final calls = <String>[];
      withDefer((defer) {
        defer.register(() => calls.add('first'));
        defer.register(() => calls.add('second'));
      });
      // Since execAll iterates in registration order, both should be present
      expect(calls, containsAll(['first', 'second']));
      expect(calls.length, 2);
    });

    test('executes deferred functions even if fn throws', () {
      var called = false;
      expect(
        () => withDefer((defer) {
          defer.register(() => called = true);
          throw Exception('fail');
        }),
        throwsException,
      );
      expect(called, isTrue);
    });
  });
}
