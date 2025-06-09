import 'package:test/test.dart';
import 'package:core_std/src/defer.dart';

void main() {
  group('DeferRegistry', () {
    test('registerKey registers and executes function by key', () {
      final registry = DeferRegistry();
      var called = false;
      registry.registerKey('myKey', () {
        called = true;
      });
      registry.exec('myKey');
      expect(called, isTrue);
    });

    test('register throws if key already registered', () {
      final registry = DeferRegistry();
      registry.registerKey('dup', () {});
      expect(() => registry.registerKey('dup', () {}), throwsArgumentError);
    });

    test('register returns unique integer key', () {
      final registry = DeferRegistry();
      final key1 = registry.register(() {});
      final key2 = registry.register(() {});
      expect(key1, isNot(equals(key2)));
    });

    test('unregisterKey removes function', () {
      final registry = DeferRegistry();
      registry.registerKey('k', () {});
      registry.unregisterKey('k');
      expect(() => registry.exec('k'), throwsArgumentError);
    });

    test('unregisterKey throws if key not registered', () {
      final registry = DeferRegistry();
      expect(() => registry.unregisterKey('missing'), throwsArgumentError);
    });

    test('exec executes and removes function', () {
      final registry = DeferRegistry();
      var called = false;
      registry.registerKey('x', () {
        called = true;
      });
      registry.exec('x');
      expect(called, isTrue);
      expect(() => registry.exec('x'), throwsArgumentError);
    });

    test('exec throws if key not registered', () {
      final registry = DeferRegistry();
      expect(() => registry.exec('nope'), throwsArgumentError);
    });

    test('execAll executes all registered functions', () {
      final registry = DeferRegistry();
      var calls = <String>[];
      registry.registerKey('a', () => calls.add('a'));
      registry.registerKey('b', () => calls.add('b'));
      registry.execAll();
      expect(calls, containsAll(['a', 'b']));
      expect(() => registry.exec('a'), throwsArgumentError);
      expect(() => registry.exec('b'), throwsArgumentError);
    });

    test('keys returns all registered keys', () {
      final registry = DeferRegistry();
      final key1 = registry.register(() {});
      registry.registerKey('custom', () {});
      expect(registry.keys, containsAll([key1, 'custom']));
      expect(registry.keys.length, 2);
    });

    test('keys is updated after unregister and exec', () {
      final registry = DeferRegistry();
      final key1 = registry.register(() {});
      registry.registerKey('another', () {});
      registry.unregisterKey(key1);
      expect(registry.keys, contains('another'));
      expect(registry.keys, isNot(contains(key1)));
      registry.exec('another');
      expect(registry.keys, isEmpty);
    });
  });
}
