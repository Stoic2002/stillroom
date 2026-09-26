import '../actions/game_action.dart';
import '../json/json_reader.dart';
import 'scene.dart';

final class ItemDef {
  const ItemDef({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.icon,
    this.examine,
  });

  factory ItemDef.fromJson(JsonReader json, ActionRegistry actions) {
    json.allowOnly({'id', 'nameKey', 'descKey', 'icon', 'examine'});
    final examine = json.optionalObject('examine');
    return ItemDef(
      id: json.string('id'),
      nameKey: json.string('nameKey'),
      descKey: json.string('descKey'),
      icon: json.string('icon'),
      examine: examine == null ? null : ItemExamine.fromJson(examine, actions),
    );
  }

  final String id;
  final String nameKey;
  final String descKey;
  final String icon;

  /// Close-up view with its own hotspots. `null` means the examine view shows
  /// only the icon and description.
  final ItemExamine? examine;
}

/// The close-up view of an item, e.g. a small box whose lid can be opened.
/// The image is square; hotspot and layer rects are normalized to it.
final class ItemExamine {
  const ItemExamine({
    required this.image,
    this.hotspots = const [],
    this.layers = const [],
  });

  factory ItemExamine.fromJson(JsonReader json, ActionRegistry actions) {
    json.allowOnly({'image', 'hotspots', 'layers'});
    final hotspots = [
      for (final h in json.objects('hotspots', optional: true))
        Hotspot.fromJson(h, actions),
    ];
    final layers = [
      for (final l in json.objects('layers', optional: true))
        SceneLayer.fromJson(l),
    ];
    for (final (key, ids) in [
      ('hotspots', hotspots.map((h) => h.id)),
      ('layers', layers.map((l) => l.id)),
    ]) {
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) json.fail('duplicate id "$id"', key);
      }
    }
    return ItemExamine(
      image: json.string('image'),
      hotspots: hotspots,
      layers: layers,
    );
  }

  final String image;

  /// Later entries are on top, as in scenes.
  final List<Hotspot> hotspots;

  /// Drawn over [image] while their conditions hold (e.g. an opened lid).
  final List<SceneLayer> layers;

  Hotspot? hotspot(String id) {
    for (final h in hotspots) {
      if (h.id == id) return h;
    }
    return null;
  }
}

/// `a` + `b` → `result`. Order does not matter.
final class Combination {
  const Combination({required this.a, required this.b, required this.result});

  factory Combination.fromJson(JsonReader json) {
    json.allowOnly({'a', 'b', 'result'});
    final a = json.string('a');
    final b = json.string('b');
    if (a == b) json.fail('an item cannot be combined with itself');
    return Combination(a: a, b: b, result: json.string('result'));
  }

  final String a;
  final String b;
  final String result;

  bool matches(String x, String y) => (a == x && b == y) || (a == y && b == x);
}
