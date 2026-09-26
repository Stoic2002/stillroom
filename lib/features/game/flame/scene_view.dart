import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/art/vector_art.dart';
import '../../../engine/engine.dart';
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
    game.handleSceneTap(p.x / size.x, p.y / size.y);
  }
}
