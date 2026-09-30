import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import 'darkness_overlay.dart';
import 'lens_view.dart';
import 'scene_view.dart';
import 'tap_ripple.dart';

/// Called with a tap position and the minimum tap area, all normalized to
/// the scene (0–1).
typedef SceneTapCallback =
    void Function(double x, double y, double minWidth, double minHeight);

/// Renders the current scene at a fixed logical resolution, letterboxed to
/// the screen, and fades between scenes. It only displays [GameState]; input
/// goes back out through [onSceneTap].
class StillroomGame extends FlameGame {
  StillroomGame({
    required this.engine,
    required this.assetPaths,
    required GameState initialState,
    required this.onSceneTap,
    this.onLensTap,
    this.onAmbientSound,
    bool showHotspots = false,
  }) : _state = initialState,
       _showHotspots = showHotspots,
       logicalSize = Vector2(
         engine.content.config.logicalWidth.toDouble(),
         engine.content.config.logicalHeight.toDouble(),
       ),
       super(
         camera: CameraComponent.withFixedResolution(
           width: engine.content.config.logicalWidth.toDouble(),
           height: engine.content.config.logicalHeight.toDouble(),
         ),
       ) {
    // Content paths are relative to assets/ (e.g. images/scenes/desk.png).
    images = Images(prefix: 'assets/');
  }

  /// Minimum tap area on the physical screen (NFR-05).
  static const minTapSizeDp = 44.0;

  final GameEngine engine;

  /// Bundled asset paths (`assets/...`), to decide between art and placeholder.
  final Set<String> assetPaths;
  final SceneTapCallback onSceneTap;

  /// A tap inside the raised lens, normalized to the scene; it belongs to
  /// the scene seen through the lens.
  final SceneTapCallback? onLensTap;

  /// Plays a creature's sound (a content sound id), quietly.
  final void Function(String soundId)? onAmbientSound;
  final Vector2 logicalSize;

  GameState _state;
  bool _showHotspots;
  SceneView? _view;
  LensView? _lens;
  Map<String, Sprite> _sprites = const {};
  bool _lensUp = false;
  Set<String> _loadedImages = {};
  late final RectangleComponent _fade;
  late final DarknessOverlay _darkness;
  bool _transitioning = false;

  @override
  Color backgroundColor() => StillroomPalette.ink;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    _fade = RectangleComponent(
      size: logicalSize,
      paint: Paint()..color = StillroomPalette.ink,
      priority: 1000,
    )..opacity = 0;
    _darkness = DarknessOverlay(size: logicalSize);
    world
      ..add(_fade)
      ..add(_darkness);
    await _showCurrentScene();
    // The state may have moved on while the first scene was loading.
    if (_view?.scene.id != _state.sceneId) unawaited(_transition());
  }

  void updateState(GameState state) {
    final sceneChanged = state.sceneId != _state.sceneId;
    _state = state;
    if (!isLoaded) return;
    if (sceneChanged) {
      unawaited(_transition());
    } else if (!_transitioning) {
      _view?.refresh(state);
      _lens?.refresh(state);
      _updateDarkness();
      _updateLens();
      unawaited(_turnLens());
    }
  }

  /// Whether the player holds the lens up. It shows wherever the current
  /// scene has a lens they can use right now.
  bool get lensUp => _lensUp;
  set lensUp(bool value) {
    _lensUp = value;
    _updateLens();
  }

  void _updateLens() =>
      _lens?.shown = _lensUp && engine.lens(_state) != null && !_transitioning;

  /// Pushes a raised lens by [delta] logical pixels.
  void moveLensBy(Vector2 delta) => _lens?.moveBy(delta);

  /// Moves the lantern light in a dark scene to a point of the scene
  /// (normalized).
  void moveLight(double x, double y) =>
      _darkness.light = Vector2(x, y)..multiply(logicalSize);

  void _updateDarkness() {
    final dark = engine.darkness(_state);
    _darkness.radius = dark == null ? null : dark.radius * logicalSize.x;
  }

  set showHotspots(bool value) {
    _showHotspots = value;
    _view?.showHotspots = value;
  }

  /// Small camera shake (the `shake` action). [strength] is 0–1.
  void shake({required int durationMs, required double strength}) {
    if (!isLoaded || strength <= 0) return;
    const period = 0.06;
    final repeats = math.max(1, (durationMs / 1000 / period).round());
    // Zigzag ends where it started, so overlapping shakes never drift.
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(maxShakeOffset * strength, maxShakeOffset * strength * 0.4),
        RepeatedEffectController(
          ZigzagEffectController(period: period),
          repeats,
        ),
      ),
    );
  }

  /// Shake amplitude at strength 1, in logical pixels.
  static const maxShakeOffset = 28.0;

  void handleSceneTap(double x, double y) {
    if (_transitioning) return;
    final point = Vector2(x, y)..multiply(logicalSize);
    final lens = _lens;
    final inLens = lens != null && lens.holds(point);
    if (!inLens) moveLight(x, y);
    world.add(TapRipple(position: point));
    final scale = math.min(size.x / logicalSize.x, size.y / logicalSize.y);
    final minWidth = minTapSizeDp / (logicalSize.x * scale);
    final minHeight = minTapSizeDp / (logicalSize.y * scale);
    if (inLens) {
      onLensTap?.call(x, y, minWidth, minHeight);
    } else {
      onSceneTap(x, y, minWidth, minHeight);
    }
  }

  /// Fades out, swaps to the scene of the latest state, and fades in. State
  /// updates that arrive mid-transition are picked up at the swap.
  Future<void> _transition() async {
    if (_transitioning) return;
    _transitioning = true;
    final half = engine.content.config.sceneTransitionMs / 2000;
    _lens?.shown = false;
    if (half > 0) await _fadeTo(1, half);
    await _showCurrentScene();
    if (half > 0) await _fadeTo(0, half);
    _transitioning = false;
    if (_view?.scene.id != _state.sceneId) {
      await _transition();
    } else {
      _view?.refresh(_state);
      _lens?.refresh(_state);
      _updateLens();
    }
  }

  Future<void> _fadeTo(double opacity, double seconds) {
    final done = Completer<void>();
    _fade.add(
      OpacityEffect.to(
        opacity,
        EffectController(duration: seconds),
        onComplete: done.complete,
      ),
    );
    return done.future;
  }

  /// Loads only the art the current scene uses and releases the previous
  /// scene's images (NFR-01).
  Future<void> _showCurrentScene() async {
    final scene = engine.currentScene(_state);
    // Every hour the lens can show, so turning it needs no loading.
    final lensScenes = [
      for (final id in scene.lens?.scenes ?? const <String>[])
        engine.content.requireScene(id),
    ];
    final paths = {
      for (final s in [scene, ...lensScenes]) ...[
        s.background,
        for (final layer in s.layers) layer.image,
      ],
    }.where((p) => assetPaths.contains('assets/$p')).toSet();

    final sprites = <String, Sprite>{
      for (final path in paths) path: Sprite(await images.load(path)),
    };
    for (final stale in _loadedImages.difference(paths)) {
      images.clear(stale);
    }
    _loadedImages = paths;
    _sprites = sprites;

    _view?.removeFromParent();
    final view = SceneView(
      scene: scene,
      sprites: sprites,
      state: _state,
      showHotspots: _showHotspots,
      size: logicalSize,
    );
    _view = view;
    await world.add(view);

    _lens?.removeFromParent();
    _lens = null;
    await _placeLens();
    _updateDarkness();
    _updateLens();
  }

  /// Puts up the lens view of the current scene, looking at the hour the
  /// lens is turned to; [at] keeps its place when the hour changes.
  Future<void> _placeLens({Vector2? at, bool open = false}) async {
    final lens = engine.currentScene(_state).lens;
    if (lens == null) return;
    final view = LensView(
      scene: engine.content.requireScene(lens.sceneAt(engine.lensHour(_state))),
      sprites: _sprites,
      state: _state,
      radius: lens.radius * logicalSize.x,
      size: logicalSize,
      center: at,
      open: open,
    );
    _lens = view;
    await world.add(view);
  }

  /// The lens was turned to another hour: show that hour in its place.
  Future<void> _turnLens() async {
    final old = _lens;
    if (old == null) return;
    final lens = engine.currentScene(_state).lens;
    if (lens == null || old.scene.id == lens.sceneAt(engine.lensHour(_state))) {
      return;
    }
    _lens = null;
    await _placeLens(at: old.lensCenter.clone(), open: old.shown);
    old.removeFromParent();
    _updateLens();
  }
}
