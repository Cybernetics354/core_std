import 'package:core_std/src/future_extension.dart';

Future<void> main() async {
  // Example: withError on a successful future
  final (error1, value1) = await Future.value(42).withError();
  print('Future.withError (success): error=$error1, value=$value1'); // error=null, value=42

  // Example: withError on a failed future
  final (error2, value2) = await Future<int>.error('fail').withError();
  print('Future.withError (error): error=$error2, value=$value2'); // error=fail, value=null

  // Example: withFallback on a successful future
  final fallback1 = await Future.value('ok').withFallback('fallback');
  print('Future.withFallback (success): $fallback1'); // ok

  // Example: withFallback on a failed future
  final fallback2 = await Future<String>.error('fail').withFallback('fallback');
  print('Future.withFallback (error): $fallback2'); // fallback

  // Example: thenWithCatch on a successful future
  final processed1 = await Future.value(5).thenWithCatch((error, value) {
    if (error != null) return -1;
    return value! * 2;
  });
  print('Future.thenWithCatch (success): $processed1'); // 10

  // Example: thenWithCatch on a failed future
  final processed2 = await Future<int>.error('fail').thenWithCatch((error, value) {
    if (error != null) return -1;
    return value!;
  });
  print('Future.thenWithCatch (error): $processed2'); // -1
}