import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

/// [KeyValueStore] backed by `shared_preferences` (cached, so reads are
/// synchronous).
final class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<SharedPreferencesStore> create() async =>
      SharedPreferencesStore._(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(),
        ),
      );

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
