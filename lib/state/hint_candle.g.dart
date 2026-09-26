// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hint_candle.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hintPacing)
final hintPacingProvider = HintPacingProvider._();

final class HintPacingProvider
    extends $FunctionalProvider<HintPacing, HintPacing, HintPacing>
    with $Provider<HintPacing> {
  HintPacingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hintPacingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hintPacingHash();

  @$internal
  @override
  $ProviderElement<HintPacing> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HintPacing create(Ref ref) {
    return hintPacing(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HintPacing value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HintPacing>(value),
    );
  }
}

String _$hintPacingHash() => r'74170518636ecd0e79dcb8438214eb0ac457d0c5';

/// The hint candles of one episode: how long each hint group (a stage or a
/// puzzle) has burned since its last hint was read. The game screen burns
/// the current group's candle while the player is playing.
///
/// Kept in memory only: after the app restarts, the candles start again.

@ProviderFor(HintCandle)
final hintCandleProvider = HintCandleFamily._();

/// The hint candles of one episode: how long each hint group (a stage or a
/// puzzle) has burned since its last hint was read. The game screen burns
/// the current group's candle while the player is playing.
///
/// Kept in memory only: after the app restarts, the candles start again.
final class HintCandleProvider
    extends $NotifierProvider<HintCandle, Map<String, Duration>> {
  /// The hint candles of one episode: how long each hint group (a stage or a
  /// puzzle) has burned since its last hint was read. The game screen burns
  /// the current group's candle while the player is playing.
  ///
  /// Kept in memory only: after the app restarts, the candles start again.
  HintCandleProvider._({
    required HintCandleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hintCandleProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hintCandleHash();

  @override
  String toString() {
    return r'hintCandleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HintCandle create() => HintCandle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Duration> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Duration>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HintCandleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hintCandleHash() => r'770cb18457dfecb4f112b7c9d680bcf05f802438';

/// The hint candles of one episode: how long each hint group (a stage or a
/// puzzle) has burned since its last hint was read. The game screen burns
/// the current group's candle while the player is playing.
///
/// Kept in memory only: after the app restarts, the candles start again.

final class HintCandleFamily extends $Family
    with
        $ClassFamilyOverride<
          HintCandle,
          Map<String, Duration>,
          Map<String, Duration>,
          Map<String, Duration>,
          String
        > {
  HintCandleFamily._()
    : super(
        retry: null,
        name: r'hintCandleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The hint candles of one episode: how long each hint group (a stage or a
  /// puzzle) has burned since its last hint was read. The game screen burns
  /// the current group's candle while the player is playing.
  ///
  /// Kept in memory only: after the app restarts, the candles start again.

  HintCandleProvider call(String episodeId) =>
      HintCandleProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'hintCandleProvider';
}

/// The hint candles of one episode: how long each hint group (a stage or a
/// puzzle) has burned since its last hint was read. The game screen burns
/// the current group's candle while the player is playing.
///
/// Kept in memory only: after the app restarts, the candles start again.

abstract class _$HintCandle extends $Notifier<Map<String, Duration>> {
  late final _$args = ref.$arg as String;
  String get episodeId => _$args;

  Map<String, Duration> build(String episodeId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Duration>, Map<String, Duration>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Duration>, Map<String, Duration>>,
              Map<String, Duration>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
