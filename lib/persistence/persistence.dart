/// Persistence for application.
abstract class Persistence {
  /// Get the currently item with the given [key]
  ///
  /// returns `null` if not set
  Future<String> get(String key);

  /// Gets a list of strings under the given [key]
  Future<List<String>> getList(String key);

  /// Stores the [value] under the given [key]
  Future<void> set(String key, String value);

  /// Removes the [key], i.e sets token to `null`
  Future<void> remove(String key);

  /// Clear all entries
  Future<void> clear();
}
