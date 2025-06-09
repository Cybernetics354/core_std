import 'package:test/test.dart';
import 'package:core_std/src/future_extension.dart';

void main() {
  group('FutureExtension', () {
    test('withError returns result on success', () async {
      final future = Future.value(10);
      final (error, result) = await future.withError();
      expect(error, isNull);
      expect(result, 10);
    });

    test('withError returns error on failure', () async {
      final future = Future<int>.error('fail');
      final (error, result) = await future.withError();
      expect(error, isNotNull);
      expect(result, isNull);
    });

    test('withFallback returns value on success', () async {
      final future = Future.value('ok');
      final result = await future.withFallback('fallback');
      expect(result, 'ok');
    });

    test('withFallback returns fallback on error', () async {
      final future = Future<String>.error('fail');
      final result = await future.withFallback('fallback');
      expect(result, 'fallback');
    });

    test('thenWithCatch returns processed value on success', () async {
      final future = Future.value(5);
      final processed = await future.thenWithCatch((error, value) {
        if (error != null) return -1;
        return value! * 2;
      });
      expect(processed, 10);
    });

    test('thenWithCatch returns processed value on error', () async {
      final future = Future<int>.error('fail');
      final processed = await future.thenWithCatch((error, value) {
        if (error != null) return -1;
        return value!;
      });
      expect(processed, -1);
    });
  });
}