/// Small persistent string store. Wraps the storage plugin (PRD §6.3) so it
/// can be swapped, and replaced by [MemoryKeyValueStore] in tests.
///
/// Reads are synchronous (values are cached in memory after start-up);
/// writes are asynchronous.
abstract interface class KeyValueStore {
  String? getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

/// In-memory store for tests and previews.
final class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  String? getString(String key) => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
