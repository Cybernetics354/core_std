import 'package:core_std/src/utils.dart';

void main() {
  // Example: runAsync
  final call = runAsync(() async => 42);
  call.exec().then((result) => print('runAsync: $result')); // Should print 42

  // Example: switchMap
  final map = {'a': 1, 'b': 2};
  final result1 = switchMap('a', map, fallback: 0);
  final result2 = switchMap('c', map, fallback: 0);
  print('switchMap: $result1'); // Should print 1
  print('switchMap (fallback): $result2'); // Should print 0

  // Example: withDefer
  final log = <String>[];
  withDefer((defer) {
    defer.register(() => log.add('cleanup'));
    log.add('work');
  });
  print('withDefer: $log'); // Should print ['work', 'cleanup']
}