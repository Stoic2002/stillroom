import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
import 'puzzle_type.dart';

/// `beamSweep`: a lighthouse beam turns over a dark landscape, and things
/// show only while it passes. Tap each target while the beam is on it.
///
/// ```json
/// "config": {
///   "pivot": [0.5, 0.08],
///   "period": 8,
///   "spread": 0.2,
///   "targets": [
///     { "id": "rail", "rect": [0.6, 0.6, 0.1, 0.06], "labelKey": "..." }
///   ]
/// }
/// ```
/// The beam turns clockwise round `pivot` (normalized, where the lamp is)
/// once every `period` seconds (default 8), starting pointing right.
/// `spread` is half the beam's width in radians (default 0.2). A target is
/// lit while the beam's centre line is within `spread` of the target's
/// centre, as seen from the pivot. Tapping a lit target finds it; tapping it
/// in the dark is a miss. Solved when every target is found. `labelKey`
/// (optional) is written beside a found target.
final class BeamSweepType implements PuzzleType {
  const BeamSweepType();

  static const typeId = 'beamSweep';

  @override
  String get id => typeId;

  @override
  BeamSweepConfig parseConfig(JsonReader json) {
    json.allowOnly({'pivot', 'period', 'spread', 'targets'});
    final pivot = json.numbers('pivot', length: 2);
    if (pivot.any((v) => v < 0 || v > 1)) {
      json.fail('must be within 0–1', 'pivot');
    }
    final period = json.optionalNumber('period') ?? 8;
    if (period < 2 || period > 60) json.fail('must be 2–60 seconds', 'period');
    final spread = json.optionalNumber('spread') ?? 0.2;
    if (spread <= 0 || spread > 1) {
      json.fail('must be above 0, at most 1', 'spread');
    }
    final targets = [
      for (final t in json.objects('targets')) BeamTarget._fromJson(t),
    ];
    if (targets.isEmpty) json.fail('need at least one target', 'targets');
    final ids = {for (final t in targets) t.id};
    if (ids.length != targets.length) {
      json.fail('target ids must be unique', 'targets');
    }
    return BeamSweepConfig(
      pivotX: pivot[0],
      pivotY: pivot[1],
      period: period,
      spread: spread,
      targets: targets,
    );
  }
}

final class BeamTarget {
  const BeamTarget({required this.id, required this.rect, this.labelKey});

  factory BeamTarget._fromJson(JsonReader json) {
    json.allowOnly({'id', 'rect', 'labelKey'});
    final rect = NormalizedRect.fromJson(json, 'rect');
    if (!rect.isWithinUnit) json.fail('must lie within 0–1', 'rect');
    return BeamTarget(
      id: json.string('id'),
      rect: rect,
      labelKey: json.optionalString('labelKey'),
    );
  }

  final String id;
  final NormalizedRect rect;
  final String? labelKey;

  double get centerX => rect.x + rect.width / 2;
  double get centerY => rect.y + rect.height / 2;
}

final class BeamSweepConfig implements PuzzleConfig {
  BeamSweepConfig({
    required this.pivotX,
    required this.pivotY,
    required this.period,
    required this.spread,
    required List<BeamTarget> targets,
  }) : targets = List.unmodifiable(targets);

  final double pivotX;
  final double pivotY;

  /// Seconds for one full turn.
  final double period;

  /// Half the beam's width, in radians.
  final double spread;
  final List<BeamTarget> targets;

  BeamTarget target(String id) => targets.firstWhere((t) => t.id == id);

  BeamSweepState start() => BeamSweepState(this, const {}, 0);

  /// The beam's direction at [seconds], in radians on screen (0 = right,
  /// growing clockwise).
  double angleAt(double seconds) => (seconds / period % 1) * 2 * math.pi;

  /// Whether [target] is in the beam at [seconds]. [aspect] is the board's
  /// width over its height, so angles match what is on screen.
  bool isLit(BeamTarget target, double seconds, {double aspect = 16 / 9}) {
    final toTarget = math.atan2(
      target.centerY - pivotY,
      (target.centerX - pivotX) * aspect,
    );
    var delta = (toTarget - angleAt(seconds)) % (2 * math.pi);
    if (delta > math.pi) delta -= 2 * math.pi;
    return delta.abs() <= spread;
  }

  @override
  Iterable<ContentRef> get references => [
    for (final t in targets)
      if (t.labelKey case final key?) ContentRef.text(key),
  ];
}

final class BeamSweepState {
  BeamSweepState(this.config, Set<String> found, this.misses)
    : found = Set.unmodifiable(found);

  final BeamSweepConfig config;
  final Set<String> found;

  /// Taps on a target while it was dark.
  final int misses;

  bool get isSolved => found.length == config.targets.length;

  /// The player tapped [targetId] at [seconds]: found if the beam is on it,
  /// a miss if it is dark. Found targets stay found.
  BeamSweepState tap(
    String targetId,
    double seconds, {
    double aspect = 16 / 9,
  }) {
    if (isSolved || found.contains(targetId)) return this;
    if (config.isLit(config.target(targetId), seconds, aspect: aspect)) {
      return BeamSweepState(config, {...found, targetId}, misses);
    }
    return BeamSweepState(config, found, misses + 1);
  }
}
