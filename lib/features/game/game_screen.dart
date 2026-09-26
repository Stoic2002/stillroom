import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/scene_frame.dart';
import '../../debug/debug_overlay.dart';
import '../../debug/debug_settings.dart';
import '../../engine/engine.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/game_session.dart';
import 'flame/stillroom_game.dart';
import 'widgets/ending_overlay.dart';
import 'widgets/exit_buttons.dart';
import 'widgets/game_effects.dart';
import 'widgets/hint_button.dart';
import 'widgets/text_box.dart';

/// Builds a widget from another feature for the running episode. Features
/// read the session themselves through `gameSessionProvider(episodeId)`.
typedef EpisodeWidgetBuilder = Widget Function(String episodeId);

/// Builds the bar beside the scene; [axis] is its main direction.
typedef EpisodeBarBuilder = Widget Function(String episodeId, Axis axis);

/// Plays one episode: the Flame scene with Flutter overlays on top.
///
/// Other features (inventory, puzzles, ...) plug in through [sideBar] and
/// [overlays], wired in `app.dart`, so features do not import each other.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    required this.episodeId,
    this.sideBar,
    this.overlays = const [],
    super.key,
  });

  final String episodeId;

  /// Shown beside the scene: on the right in landscape, below in portrait.
  final EpisodeBarBuilder? sideBar;

  /// Stacked over the scene area in order, under the text box.
  final List<EpisodeWidgetBuilder> overlays;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  StillroomGame? _game;

  GameSessionProvider get _provider => gameSessionProvider(widget.episodeId);

  StillroomGame _gameFor(GameSessionState session) {
    return _game ??= _createGame(session);
  }

  StillroomGame _createGame(GameSessionState session) {
    unawaited(_applyOrientation(session.engine.content.config.orientation));
    final notifier = ref.read(_provider.notifier);
    return StillroomGame(
      engine: session.engine,
      assetPaths: session.episode.assets,
      initialState: session.game,
      showHotspots: ref.read(showHotspotsProvider),
      onSceneTap: (x, y, minWidth, minHeight) =>
          notifier.tapScene(x, y, minWidth: minWidth, minHeight: minHeight),
    );
  }

  Future<void> _applyOrientation(ScreenOrientation orientation) =>
      SystemChrome.setPreferredOrientations(switch (orientation) {
        ScreenOrientation.landscape => const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        ScreenOrientation.portrait => const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      });

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(_provider, (previous, next) {
        if (next.value case final session?) _game?.updateState(session.game);
      })
      ..listen(showHotspotsProvider, (_, show) => _game?.showHotspots = show);

    final session = ref.watch(_provider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: switch (session) {
        AsyncData(:final value) => _GameView(
          game: _gameFor(value),
          session: value,
          episodeId: widget.episodeId,
          sideBar: widget.sideBar,
          overlays: widget.overlays,
          onExit: ref.read(_provider.notifier).takeExit,
        ),
        AsyncError(:final error) => _ContentError(error: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView({
    required this.game,
    required this.session,
    required this.episodeId,
    required this.sideBar,
    required this.overlays,
    required this.onExit,
  });

  final StillroomGame game;
  final GameSessionState session;
  final String episodeId;
  final EpisodeBarBuilder? sideBar;
  final List<EpisodeWidgetBuilder> overlays;
  final ValueChanged<String> onExit;

  @override
  Widget build(BuildContext context) {
    final config = session.engine.content.config;
    final landscape = config.orientation == ScreenOrientation.landscape;
    final sceneArea = Stack(
      fit: StackFit.expand,
      children: [
        GameWidget(game: game),
        SceneFrame(
          logicalWidth: config.logicalWidth,
          logicalHeight: config.logicalHeight,
          child: const Atmosphere(vignette: 0.75),
        ),
        SceneFrame(
          logicalWidth: config.logicalWidth,
          logicalHeight: config.logicalHeight,
          child: ExitButtons(
            exits: session.engine.visibleExits(session.game),
            onExit: onExit,
          ),
        ),
        SceneFrame(
          logicalWidth: config.logicalWidth,
          logicalHeight: config.logicalHeight,
          child: const _MenuButton(),
        ),
        for (final overlay in overlays) overlay(episodeId),
        // Above puzzle screens, so it serves puzzle and stage hints alike.
        SceneFrame(
          logicalWidth: config.logicalWidth,
          logicalHeight: config.logicalHeight,
          child: HintButton(episodeId: episodeId),
        ),
        SceneFrame(
          logicalWidth: config.logicalWidth,
          logicalHeight: config.logicalHeight,
          child: TextBox(episodeId: episodeId),
        ),
        EndingOverlay(episodeId: episodeId),
        GameEffects(
          episodeId: episodeId,
          onShake: (durationMs, strength) =>
              game.shake(durationMs: durationMs, strength: strength),
        ),
      ],
    );
    final bar = sideBar?.call(
      episodeId,
      landscape ? Axis.vertical : Axis.horizontal,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Flex(
          direction: landscape ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(child: sceneArea),
            ?bar,
          ],
        ),
        if (kDebugMode) DebugOverlay(episodeId: episodeId),
      ],
    );
  }
}

/// Back to the main menu. Progress is already saved on every change.
class _MenuButton extends StatelessWidget {
  const _MenuButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IconButton(
          tooltip: AppLocalizations.of(context).backToMenu,
          color: StillroomPalette.faded,
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _ContentError extends StatelessWidget {
  const _ContentError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contentLoadError,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (kDebugMode)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    '$error',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(l10n.backToMenu),
            ),
          ],
        ),
      ),
    );
  }
}
