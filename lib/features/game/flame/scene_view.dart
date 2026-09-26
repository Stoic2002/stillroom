import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/art/vector_art.dart';
import '../../../engine/engine.dart';
import 'creatures.dart';
import 'echo_component.dart';
import 'hotspot_outlines.dart';
import 'placeholder_box.dart';
import 'stillroom_game.dart';
import 'vector_art_component.dart';

/// Renders one scene at logical resolution: background, visible layers, and
/// (in debug) hotspot outlines. Forwards taps to the game as normalized
/// coordinates; it holds no game rules.
class SceneView extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameReference<StillroomGame> {
  SceneView({
    required this.scene,
    required this.sprites,
    required GameState state,
    required bool showHotspots,
    required super.size,
  }) : _state = state,
       _outlines = HotspotOutlines(size: size)..enabled = showHotspots;

  final Scene scene;

  /// Loaded art by asset-relative path; missing entries use placeholders.
  final Map<String, Sprite> sprites;
  final HotspotOutlines _outlines;
  final _layers = Component();
  GameState _state;

  set showHotspots(bool value) => _outlines.enabled = value;

  @override
  Future<void> onLoad() async {
    add(
      _visual(
        path: scene.background,
        label: scene.id,
        position: Vector2.zero(),
        size: size,
        background: true,
      ),
    );
    add(_layers);
    add(_outlines);
    _rebuild();
    _spawnCreatures();
    await _spawnEchoes();
  }

  /// Creatures are rolled once each time the scene is shown.
  void _spawnCreatures() {
    final random = math.Random();
    for (final c in game.engine.possibleCreatures(_state)) {
      if (random.nextDouble() > c.chance) continue;
      final r = c.rect;
      add(
        Creature.create(
          c.kind,
          Rect.fromLTWH(
            r.x * size.x,
            r.y * size.y,
            r.width * size.x,
            r.height * size.y,
          ),
          random,
          (id) => game.onAmbientSound?.call(id),
        ),
      );
    }
  }

  /// Echoes are rolled once each time the scene is shown.
  Future<void> _spawnEchoes() async {
    final random = math.Random();
    for (final echo in game.engine.possibleEchoes(_state)) {
      if (random.nextDouble() > echo.chance) continue;
      final r = echo.rect;
      final box = Vector2(r.width * size.x, r.height * size.y);
      final image = await _imageFor(echo.image, box);
      if (image == null || !isMounted) continue;
      add(
        EchoComponent(
          image: image,
          drift: Vector2(echo.driftX * size.x, echo.driftY * size.y),
          random: random,
          position: Vector2(r.x * size.x, r.y * size.y),
          size: box,
        ),
      );
    }
  }

  /// A raster of [path]: its bundled file, else its code-drawn art.
  Future<Image?> _imageFor(String path, Vector2 box) async {
    final sprite = sprites[path];
    if (sprite != null) return sprite.image;
    final art = vectorArtFor(path);
    if (art == null) return null;
    final recorder = PictureRecorder();
    art(Canvas(recorder), box.toSize());
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      box.x.ceil().clamp(1, 4096),
      box.y.ceil().clamp(1, 4096),
    );
    picture.dispose();
    return image;
  }

  void refresh(GameState state) {
    _state = state;
    if (isLoaded) _rebuild();
  }

  void _rebuild() {
    final engine = game.engine;
    _layers.removeAll(_layers.children);
    for (final layer in engine.visibleLayers(_state)) {
      final r = layer.rect;
      _layers.add(
        _visual(
          path: layer.image,
          label: layer.id,
          position: Vector2(r.x * size.x, r.y * size.y),
          size: Vector2(r.width * size.x, r.height * size.y),
          background: false,
        ),
      );
    }
    _outlines
      ..hotspots = engine.visibleHotspots(_state)
      ..exits = engine.visibleExits(_state);
  }

  PositionComponent _visual({
    required String path,
    required String label,
    required Vector2 position,
    required Vector2 size,
    required bool background,
  }) {
    final sprite = sprites[path];
    if (sprite != null) {
      return SpriteComponent(sprite: sprite, position: position, size: size);
    }
    final art = vectorArtFor(path);
    if (art != null) {
      return VectorArtComponent(art, position: position, size: size);
    }
    return PlaceholderBox(
      label: label,
      background: background,
      position: position,
      size: size,
    );
  }

  /// In a dark scene the lantern follows the finger.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _moveLight(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) =>
      _moveLight(event.localEndPosition);

  void _moveLight(Vector2 p) => game.moveLight(p.x / size.x, p.y / size.y);

  @override
  void onTapUp(TapUpEvent event) {
    final p = event.localPosition;
    // A tap near a creature startles it; the tap still counts below.
    for (final creature in children.whereType<Creature>()) {
      if (creature.near(p.toOffset())) creature.startle();
    }
    // Reaching for an echo makes it go; the tap still counts below.
    for (final echo in children.whereType<EchoComponent>()) {
      if (echo.isVisible &&
          echo.toRect().inflate(size.x * 0.04).contains(p.toOffset())) {
        echo.dissolve();
      }
    }
    game.handleSceneTap(p.x / size.x, p.y / size.y);
  }
}
