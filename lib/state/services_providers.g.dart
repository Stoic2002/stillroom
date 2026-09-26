// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hints wait for their candle (docs/stillroom_frame.md).

@ProviderFor(hintGate)
final hintGateProvider = HintGateProvider._();

/// Hints wait for their candle (docs/stillroom_frame.md).

final class HintGateProvider
    extends $FunctionalProvider<HintGate, HintGate, HintGate>
    with $Provider<HintGate> {
  /// Hints wait for their candle (docs/stillroom_frame.md).
  HintGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hintGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hintGateHash();

  @$internal
  @override
  $ProviderElement<HintGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HintGate create(Ref ref) {
    return hintGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HintGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HintGate>(value),
    );
  }
}

String _$hintGateHash() => r'3747946214c793431255f02b3569063b36e553cd';

@ProviderFor(audioService)
final audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  AudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'abd217d09cf61dd97cf46709df460347609e0d16';
