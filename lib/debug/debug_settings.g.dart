// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether hotspot and exit outlines are drawn over the scene.

@ProviderFor(ShowHotspots)
final showHotspotsProvider = ShowHotspotsProvider._();

/// Whether hotspot and exit outlines are drawn over the scene.
final class ShowHotspotsProvider extends $NotifierProvider<ShowHotspots, bool> {
  /// Whether hotspot and exit outlines are drawn over the scene.
  ShowHotspotsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showHotspotsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showHotspotsHash();

  @$internal
  @override
  ShowHotspots create() => ShowHotspots();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showHotspotsHash() => r'8837030ac4b598f5ec5ecea4e08982dcb87a61bb';

/// Whether hotspot and exit outlines are drawn over the scene.

abstract class _$ShowHotspots extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
