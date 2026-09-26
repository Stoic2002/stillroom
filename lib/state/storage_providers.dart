import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/storage/key_value_store.dart';

part 'storage_providers.g.dart';

/// Persistent store. `main.dart` overrides this with the real
/// `shared_preferences` store after it is opened.
@Riverpod(keepAlive: true)
KeyValueStore keyValueStore(Ref ref) =>
    throw UnimplementedError('keyValueStoreProvider must be overridden');
