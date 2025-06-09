/// A registry for managing deferred function execution.
///
/// Allows registering, executing, and unregistering functions by key.
/// Useful for cleanup, teardown, or deferred resource management.
class DeferRegistry {
  /// Internal map of registered deferred functions.
  final Map<dynamic, Function> _deferMap = {};

  /// Registers a deferred function with a unique [key].
  ///
  /// Throws [ArgumentError] if the [key] is already registered.
  /// Returns the [key] for convenience.
  S registerKey<T, S>(S key, T Function() func) {
    if (_deferMap.containsKey(key)) {
      throw ArgumentError('Key $key is already registered.');
    }
    _deferMap[key] = func;
    return key;
  }

  /// Registers a deferred function and returns an auto-generated integer key.
  ///
  /// The key is guaranteed to be unique within this registry.
  int register<T>(T Function() func) {
    final key = _deferMap.length; // Use length as a simple unique key
    registerKey(key, func);
    return key;
  }

  /// Unregisters a deferred function by [key].
  ///
  /// Throws [ArgumentError] if the [key] is not registered.
  void unregisterKey(dynamic key) {
    if (!_deferMap.containsKey(key)) {
      throw ArgumentError('Key $key is not registered.');
    }
    _deferMap.remove(key);
  }

  /// Executes and removes the deferred function associated with [key].
  ///
  /// Throws [ArgumentError] if the [key] is not registered.
  void exec(dynamic key) {
    if (!_deferMap.containsKey(key)) {
      throw ArgumentError('Key $key is not registered.');
    }
    final func = _deferMap.remove(key);
    func?.call();
  }

  /// Executes and removes all registered deferred functions.
  void execAll() {
    final keys = _deferMap.keys.toList();
    for (var key in keys) {
      exec(key);
    }
  }

  /// Returns a list of all currently registered keys.
  ///
  /// Example:
  /// ```dart
  /// print(registry.keys); // [0, 'cleanup', ...]
  /// ```
  List<dynamic> get keys => _deferMap.keys.toList();
}
