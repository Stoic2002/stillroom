// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assetSource)
final assetSourceProvider = AssetSourceProvider._();

final class AssetSourceProvider
    extends $FunctionalProvider<AssetSource, AssetSource, AssetSource>
    with $Provider<AssetSource> {
  AssetSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetSourceHash();

  @$internal
  @override
  $ProviderElement<AssetSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetSource create(Ref ref) {
    return assetSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetSource>(value),
    );
  }
}

String _$assetSourceHash() => r'b04bb222a723188885efb60ce4f0a86c8a11458a';

@ProviderFor(contentLoader)
final contentLoaderProvider = ContentLoaderProvider._();

final class ContentLoaderProvider
    extends $FunctionalProvider<ContentLoader, ContentLoader, ContentLoader>
    with $Provider<ContentLoader> {
  ContentLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentLoaderHash();

  @$internal
  @override
  $ProviderElement<ContentLoader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContentLoader create(Ref ref) {
    return contentLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentLoader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentLoader>(value),
    );
  }
}

String _$contentLoaderHash() => r'0d23106822777d19eb16754ce163dd82656bee2a';

/// Action and puzzle types known to the content parser.

@ProviderFor(contentRegistries)
final contentRegistriesProvider = ContentRegistriesProvider._();

/// Action and puzzle types known to the content parser.

final class ContentRegistriesProvider
    extends
        $FunctionalProvider<
          ContentRegistries,
          ContentRegistries,
          ContentRegistries
        >
    with $Provider<ContentRegistries> {
  /// Action and puzzle types known to the content parser.
  ContentRegistriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentRegistriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentRegistriesHash();

  @$internal
  @override
  $ProviderElement<ContentRegistries> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContentRegistries create(Ref ref) {
    return contentRegistries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContentRegistries value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContentRegistries>(value),
    );
  }
}

String _$contentRegistriesHash() => r'9b0be806f5f641b7e43f05372aa63b17f4146e01';

/// Whether to validate content on load. On in debug builds (PRD §6.1).

@ProviderFor(validateContent)
final validateContentProvider = ValidateContentProvider._();

/// Whether to validate content on load. On in debug builds (PRD §6.1).

final class ValidateContentProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether to validate content on load. On in debug builds (PRD §6.1).
  ValidateContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validateContentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validateContentHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return validateContent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$validateContentHash() => r'3b9f6e5fa4eb6b99e4908f968a8d8219772c3d2a';

/// Jars on the shelf. Debug-only episodes (the test room) are hidden in
/// release builds. Kept for the whole run: it is small and never changes.

@ProviderFor(episodeCatalog)
final episodeCatalogProvider = EpisodeCatalogProvider._();

/// Jars on the shelf. Debug-only episodes (the test room) are hidden in
/// release builds. Kept for the whole run: it is small and never changes.

final class EpisodeCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EpisodeEntry>>,
          List<EpisodeEntry>,
          FutureOr<List<EpisodeEntry>>
        >
    with
        $FutureModifier<List<EpisodeEntry>>,
        $FutureProvider<List<EpisodeEntry>> {
  /// Jars on the shelf. Debug-only episodes (the test room) are hidden in
  /// release builds. Kept for the whole run: it is small and never changes.
  EpisodeCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'episodeCatalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$episodeCatalogHash();

  @$internal
  @override
  $FutureProviderElement<List<EpisodeEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EpisodeEntry>> create(Ref ref) {
    return episodeCatalog(ref);
  }
}

String _$episodeCatalogHash() => r'38fac223fba871dec4275cc61e188da710968965';

/// Every bundled asset path, to choose between art and placeholders.

@ProviderFor(bundledAssets)
final bundledAssetsProvider = BundledAssetsProvider._();

/// Every bundled asset path, to choose between art and placeholders.

final class BundledAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Every bundled asset path, to choose between art and placeholders.
  BundledAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bundledAssetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bundledAssetsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return bundledAssets(ref);
  }
}

String _$bundledAssetsHash() => r'f2a4f3858ec57a4a184d04607b3314cdb06a80f9';

/// String tables for UI outside a running episode (e.g. jar labels).

@ProviderFor(contentStrings)
final contentStringsProvider = ContentStringsProvider._();

/// String tables for UI outside a running episode (e.g. jar labels).

final class ContentStringsProvider
    extends
        $FunctionalProvider<
          AsyncValue<StringTables>,
          StringTables,
          FutureOr<StringTables>
        >
    with $FutureModifier<StringTables>, $FutureProvider<StringTables> {
  /// String tables for UI outside a running episode (e.g. jar labels).
  ContentStringsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contentStringsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contentStringsHash();

  @$internal
  @override
  $FutureProviderElement<StringTables> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StringTables> create(Ref ref) {
    return contentStrings(ref);
  }
}

String _$contentStringsHash() => r'f8e919cad869d16acb03daa167b90ddccb1c5634';

/// Loads an episode. With validation on, content errors throw
/// [ContentValidationException] so they are fixed before anything renders.

@ProviderFor(loadedEpisode)
final loadedEpisodeProvider = LoadedEpisodeFamily._();

/// Loads an episode. With validation on, content errors throw
/// [ContentValidationException] so they are fixed before anything renders.

final class LoadedEpisodeProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoadedEpisode>,
          LoadedEpisode,
          FutureOr<LoadedEpisode>
        >
    with $FutureModifier<LoadedEpisode>, $FutureProvider<LoadedEpisode> {
  /// Loads an episode. With validation on, content errors throw
  /// [ContentValidationException] so they are fixed before anything renders.
  LoadedEpisodeProvider._({
    required LoadedEpisodeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'loadedEpisodeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$loadedEpisodeHash();

  @override
  String toString() {
    return r'loadedEpisodeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LoadedEpisode> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoadedEpisode> create(Ref ref) {
    final argument = this.argument as String;
    return loadedEpisode(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LoadedEpisodeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$loadedEpisodeHash() => r'051752547b56adfa5c5d65e1e661170c24e3d9a0';

/// Loads an episode. With validation on, content errors throw
/// [ContentValidationException] so they are fixed before anything renders.

final class LoadedEpisodeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LoadedEpisode>, String> {
  LoadedEpisodeFamily._()
    : super(
        retry: null,
        name: r'loadedEpisodeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Loads an episode. With validation on, content errors throw
  /// [ContentValidationException] so they are fixed before anything renders.

  LoadedEpisodeProvider call(String episodeId) =>
      LoadedEpisodeProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'loadedEpisodeProvider';
}
