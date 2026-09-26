import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `rotaryAlign`: concentric rings, each turned in steps until every ring is
/// at its target. Tapping a ring turns it one step clockwise; `links` make a
/// ring drag others along.
///
/// ```json
/// "config": {
///   "rings": [
///     { "id": "outer", "steps": 8, "initial": 3, "target": 0,
///       "image": "images/...", "links": [{ "ring": "inner", "steps": 1 }] },
///     { "id": "inner", "steps": 8, "initial": 5, "target": 0 }
///   ]
/// }
/// ```
/// Rings are listed outermost first. `image` (optional) is a full circle
/// drawn rotated with the ring. Link `steps` may be negative.
final class RotaryAlignType implements PuzzleType {
  const RotaryAlignType();

  static const typeId = 'rotaryAlign';

  @override
  String get id => typeId;

  @override
  RotaryAlignConfig parseConfig(JsonReader json) {
    json.allowOnly({'rings'});
    final rings = [
      for (final r in json.objects('rings')) RotaryRing._fromJson(r),
    ];
    if (rings.isEmpty) json.fail('need at least one ring', 'rings');
    final ids = <String>{};
    for (final r in rings) {
      if (!ids.add(r.id)) json.fail('duplicate id "${r.id}"', 'rings');
    }
    for (final (i, r) in rings.indexed) {
      for (final (j, link) in r.links.indexed) {
        if (!ids.contains(link.ring) || link.ring == r.id) {
          json.fail(
            'unknown or self ring "${link.ring}"',
            'rings[$i].links[$j]',
          );
        }
      }
    }
    return RotaryAlignConfig(rings);
  }
}

final class RotaryRing {
  const RotaryRing({
    required this.id,
    required this.steps,
    required this.initial,
    required this.target,
    this.image,
    this.links = const [],
  });

  factory RotaryRing._fromJson(JsonReader json) {
    json.allowOnly({'id', 'steps', 'initial', 'target', 'image', 'links'});
    final steps = json.integer('steps');
    if (steps < 2) json.fail('must be >= 2', 'steps');
    int position(String key) {
      final v = json.integer(key);
      if (v < 0 || v >= steps) json.fail('must be within 0–${steps - 1}', key);
      return v;
    }

    return RotaryRing(
      id: json.string('id'),
      steps: steps,
      initial: position('initial'),
      target: position('target'),
      image: json.optionalString('image'),
      links: [
        for (final l in json.objects('links', optional: true))
          RingLink._fromJson(l),
      ],
    );
  }

  final String id;

  /// Positions per full turn.
  final int steps;
  final int initial;
  final int target;
  final String? image;
  final List<RingLink> links;
}

final class RingLink {
  const RingLink({required this.ring, required this.steps});

  factory RingLink._fromJson(JsonReader json) {
    json.allowOnly({'ring', 'steps'});
    return RingLink(ring: json.string('ring'), steps: json.integer('steps'));
  }

  final String ring;
  final int steps;
}

final class RotaryAlignConfig implements PuzzleConfig {
  RotaryAlignConfig(List<RotaryRing> rings) : rings = List.unmodifiable(rings);

  final List<RotaryRing> rings;

  RotaryAlignState start() =>
      RotaryAlignState(this, [for (final r in rings) r.initial]);

  int indexOf(String ringId) => rings.indexWhere((r) => r.id == ringId);

  @override
  Iterable<ContentRef> get references => [
    for (final r in rings)
      if (r.image case final image?) ContentRef.image(image),
  ];
}

final class RotaryAlignState {
  RotaryAlignState(this.config, List<int> positions)
    : positions = List.unmodifiable(positions);

  final RotaryAlignConfig config;

  /// Current step per ring, in [RotaryAlignConfig.rings] order.
  final List<int> positions;

  /// Current angle of ring [index] as a fraction of a full turn (0–1).
  double turnOf(int index) => positions[index] / config.rings[index].steps;

  /// Turns ring [index] one step clockwise, plus any linked rings.
  RotaryAlignState turn(int index) {
    final next = [...positions];
    void add(int i, int delta) {
      final steps = config.rings[i].steps;
      next[i] = ((next[i] + delta) % steps + steps) % steps;
    }

    add(index, 1);
    for (final link in config.rings[index].links) {
      add(config.indexOf(link.ring), link.steps);
    }
    return RotaryAlignState(config, next);
  }

  bool get isSolved {
    for (final (i, ring) in config.rings.indexed) {
      if (positions[i] != ring.target) return false;
    }
    return true;
  }
}
