// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persistent store. `main.dart` overrides this with the real
/// `shared_preferences` store after it is opened.

@ProviderFor(keyValueStore)
final keyValueStoreProvider = KeyValueStoreProvider._();

/// Persistent store. `main.dart` overrides this with the real
/// `shared_preferences` store after it is opened.

final class KeyValueStoreProvider
    extends $FunctionalProvider<KeyValueStore, KeyValueStore, KeyValueStore>
    with $Provider<KeyValueStore> {
  /// Persistent store. `main.dart` overrides this with the real
  /// `shared_preferences` store after it is opened.
  KeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyValueStoreHash();

  @$internal
  @override
  $ProviderElement<KeyValueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KeyValueStore create(Ref ref) {
    return keyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyValueStore>(value),
    );
  }
}

String _$keyValueStoreHash() => r'527630d230df90b4e647465f1f2a8d36dce09565';
