/// Extensions for [Future] providing utility methods for error handling and result transformation.
///
/// These extensions allow you to easily handle errors, provide fallback values,
/// and process results or errors in a unified way.
///
/// Example usage:
/// ```dart
/// final result = await someFuture.withFallback(defaultValue);
/// final (error, value) = await someFuture.withError();
/// final processed = await someFuture.thenWithCatch((error, value) => ...);
/// ```
extension FutureExtension<T> on Future<T> {
  /// Returns a new [Future] that wraps the result in a tuple of (error, result).
  ///
  /// If the future completes successfully, [error] is `null` and [result] contains the value.
  /// If the future completes with an error, [error] contains the error and [result] is `null`.
  Future<(dynamic error, T? result)> withError() async {
    try {
      final result = await this;
      return (null, result);
    } catch (error) {
      return (error, null);
    }
  }

  /// Returns a new [Future] that yields [defaultValue] if the original future completes with an error.
  ///
  /// If the future completes successfully, its value is returned.
  /// If an error occurs, [defaultValue] is returned instead.
  Future<T> withFallback(T defaultValue) async {
    try {
      return await this;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Processes the result or error of the future using the provided [callback].
  ///
  /// The [callback] receives either (null, result) if the future completes successfully,
  /// or (error, null) if the future completes with an error.
  /// The return value of [callback] is returned as the result of the new future.
  Future<S> thenWithCatch<S>(
    S Function(dynamic error, T? result) callback,
  ) async {
    try {
      final result = await this;
      return callback(null, result);
    } catch (error) {
      return callback(error, null);
    }
  }
}
