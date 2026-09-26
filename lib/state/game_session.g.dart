// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
/// means depends on whether text is showing, a puzzle or examine view is
/// open, or an item is selected. Widgets and Flame components only send input here.

@ProviderFor(GameSession)
final gameSessionProvider = GameSessionFamily._();

/// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
/// means depends on whether text is showing, a puzzle or examine view is
/// open, or an item is selected. Widgets and Flame components only send input here.
final class GameSessionProvider
    extends $AsyncNotifierProvider<GameSession, GameSessionState> {
  /// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
  /// means depends on whether text is showing, a puzzle or examine view is
  /// open, or an item is selected. Widgets and Flame components only send input here.
  GameSessionProvider._({
    required GameSessionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gameSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameSessionHash();

  @override
  String toString() {
    return r'gameSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameSession create() => GameSession();

  @override
  bool operator ==(Object other) {
    return other is GameSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameSessionHash() => r'2fe33244609a79638b712e716142be8075cc9b38';

/// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
/// means depends on whether text is showing, a puzzle or examine view is
/// open, or an item is selected. Widgets and Flame components only send input here.

final class GameSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          GameSession,
          AsyncValue<GameSessionState>,
          GameSessionState,
          FutureOr<GameSessionState>,
          String
        > {
  GameSessionFamily._()
    : super(
        retry: null,
        name: r'gameSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
  /// means depends on whether text is showing, a puzzle or examine view is
  /// open, or an item is selected. Widgets and Flame components only send input here.

  GameSessionProvider call(String episodeId) =>
      GameSessionProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'gameSessionProvider';
}

/// Wraps [GameEngine] for the UI and owns the interaction rules: what a tap
/// means depends on whether text is showing, a puzzle or examine view is
/// open, or an item is selected. Widgets and Flame components only send input here.

abstract class _$GameSession extends $AsyncNotifier<GameSessionState> {
  late final _$args = ref.$arg as String;
  String get episodeId => _$args;

  FutureOr<GameSessionState> build(String episodeId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<GameSessionState>, GameSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GameSessionState>, GameSessionState>,
              AsyncValue<GameSessionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
