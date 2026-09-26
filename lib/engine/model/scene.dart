import '../actions/game_action.dart';
import '../json/json_reader.dart';
import 'condition.dart';
import 'normalized_rect.dart';

/// One point of view: a background image plus exits, hotspots, and layers.
final class Scene {
  const Scene({
    required this.id,
    required this.background,
    this.exits = const [],
    this.hotspots = const [],
    this.layers = const [],
    this.music,
  });

  factory Scene.fromJson(JsonReader json, ActionRegistry actions) {
    json.allowOnly({
      'id',
      'background',
      'music',
      'exits',
      'hotspots',
      'layers',
    });
    final exits = [
      for (final e in json.objects('exits', optional: true))
        SceneExit.fromJson(e),
    ];
    final hotspots = [
      for (final h in json.objects('hotspots', optional: true))
        Hotspot.fromJson(h, actions),
    ];
    final layers = [
      for (final l in json.objects('layers', optional: true))
        SceneLayer.fromJson(l),
    ];
    _requireUniqueIds(json, 'exits', exits.map((e) => e.id));
    _requireUniqueIds(json, 'hotspots', hotspots.map((h) => h.id));
    _requireUniqueIds(json, 'layers', layers.map((l) => l.id));
    return Scene(
      id: json.string('id'),
      background: json.string('background'),
      exits: exits,
      hotspots: hotspots,
      layers: layers,
      music: json.optionalString('music'),
    );
  }

  final String id;

  /// Overrides the episode music while this scene is shown.
  final String? music;

  /// Image path relative to `assets/`, e.g. `images/scenes/desk.png`.
  final String background;
  final List<SceneExit> exits;

  /// Later entries are on top: they win hit tests over earlier ones.
  final List<Hotspot> hotspots;

  /// Drawn in list order over the background.
  final List<SceneLayer> layers;

  Hotspot? hotspot(String id) {
    for (final h in hotspots) {
      if (h.id == id) return h;
    }
    return null;
  }

  SceneExit? exit(String id) {
    for (final e in exits) {
      if (e.id == id) return e;
    }
    return null;
  }
}

void _requireUniqueIds(JsonReader json, String key, Iterable<String> ids) {
  final seen = <String>{};
  for (final id in ids) {
    if (!seen.add(id)) json.fail('duplicate id "$id"', key);
  }
}

enum ExitDirection { left, right, back }

/// A way to another scene: a direction button, a tap area, or both.
final class SceneExit {
  const SceneExit({
    required this.id,
    required this.to,
    this.direction,
    this.rect,
    this.when = const [],
  });

  /// `id` defaults to the direction name; it is required for exits that only
  /// have a `rect`.
  factory SceneExit.fromJson(JsonReader json) {
    json.allowOnly({'id', 'direction', 'to', 'rect', 'when'});
    final directionName = json.optionalString('direction');
    final direction = directionName == null
        ? null
        : ExitDirection.values.asNameMap()[directionName] ??
              json.fail(
                'expected one of ${ExitDirection.values.map((d) => d.name).join(', ')}',
                'direction',
              );
    final rect = json.has('rect')
        ? NormalizedRect.fromJson(json, 'rect')
        : null;
    if (direction == null && rect == null) {
      json.fail('an exit needs a direction, a rect, or both');
    }
    final id =
        json.optionalString('id') ??
        direction?.name ??
        json.fail('required when the exit has no direction', 'id');
    return SceneExit(
      id: id,
      to: json.string('to'),
      direction: direction,
      rect: rect,
      when: Condition.listFromJson(json, 'when'),
    );
  }

  final String id;

  /// Target scene id.
  final String to;
  final ExitDirection? direction;
  final NormalizedRect? rect;
  final List<Condition> when;
}

/// A tappable area on a scene (or on an examined item).
final class Hotspot {
  const Hotspot({
    required this.id,
    required this.rect,
    this.when = const [],
    this.onTap = const [],
    this.onUseItem = const [],
  });

  factory Hotspot.fromJson(JsonReader json, ActionRegistry actions) {
    json.allowOnly({'id', 'rect', 'when', 'onTap', 'onUseItem'});
    final uses = [
      for (final u in json.objects('onUseItem', optional: true))
        ItemUse.fromJson(u, actions),
    ];
    _requireUniqueIds(json, 'onUseItem', uses.map((u) => u.itemId));
    return Hotspot(
      id: json.string('id'),
      rect: NormalizedRect.fromJson(json, 'rect'),
      when: Condition.listFromJson(json, 'when'),
      onTap: actions.parseList(json, 'onTap'),
      onUseItem: uses,
    );
  }

  final String id;
  final NormalizedRect rect;

  /// The hotspot exists (is visible and tappable) only while all are met.
  final List<Condition> when;
  final List<GameAction> onTap;
  final List<ItemUse> onUseItem;

  ItemUse? useFor(String itemId) {
    for (final u in onUseItem) {
      if (u.itemId == itemId) return u;
    }
    return null;
  }
}

/// What happens when a specific inventory item is used on a hotspot.
final class ItemUse {
  const ItemUse({required this.itemId, required this.actions});

  factory ItemUse.fromJson(JsonReader json, ActionRegistry actions) {
    json.allowOnly({'item', 'actions'});
    return ItemUse(
      itemId: json.string('item'),
      actions: actions.parseList(json, 'actions'),
    );
  }

  final String itemId;
  final List<GameAction> actions;
}

/// A sprite drawn over the scene while its conditions hold.
final class SceneLayer {
  const SceneLayer({
    required this.id,
    required this.image,
    required this.rect,
    this.when = const [],
  });

  factory SceneLayer.fromJson(JsonReader json) {
    json.allowOnly({'id', 'image', 'rect', 'when'});
    return SceneLayer(
      id: json.string('id'),
      image: json.string('image'),
      rect: NormalizedRect.fromJson(json, 'rect'),
      when: Condition.listFromJson(json, 'when'),
    );
  }

  final String id;
  final String image;
  final NormalizedRect rect;
  final List<Condition> when;
}
