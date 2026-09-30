import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `scan`: a garment laid out in layers, and a probe dragged over it. A
/// needle shows the reading under the probe; nothing is revealed, only
/// measured. Find and mark the places where it reads high.
///
/// ```json
/// "config": {
///   "layers": [
///     { "id": "outer", "labelKey": "ep.scan.outer", "scale": 0.4 },
///     { "id": "inner", "labelKey": "ep.scan.inner", "scale": 1 }
///   ],
///   "spots": [
///     { "id": "stomach", "labelKey": "ep.scan.stomach",
///       "at": [0.5, 0.62], "radius": 0.1, "strength": 0.9 }
///   ],
///   "background": 0.08
/// }
/// ```
/// A layer's `scale` (above 0, up to 1; the strongest is 1) weakens every
/// spot seen through it. The reading at a point is `background` plus the
/// layer's scale times each spot's `strength` falling off with distance
/// over its `radius` (positions from 0 to 1 across the garment). A mark
/// counts where the reading is at least [ScanType.clear] and a spot not yet
/// found lies within its radius; elsewhere a mark is a mistake, but a mark
/// on a spot too faint to be sure is only faint. Every spot must read clear
/// at its centre on the strongest layer.
final class ScanType implements PuzzleType {
  const ScanType();

  static const typeId = 'scan';

  /// The reading a mark needs.
  static const clear = 0.5;

  @override
  String get id => typeId;

  @override
  ScanConfig parseConfig(JsonReader json) {
    json.allowOnly({'layers', 'spots', 'background'});
    final layers = [
      for (final l in json.objects('layers'))
        () {
          l.allowOnly({'id', 'labelKey', 'scale'});
          final scale = l.number('scale');
          if (scale <= 0 || scale > 1) l.fail('above 0, up to 1', 'scale');
          return ScanLayer(
            id: l.string('id'),
            labelKey: l.string('labelKey'),
            scale: scale,
          );
        }(),
    ];
    if (layers.isEmpty || layers.length > 3) {
      json.fail('need 1 to 3 layers', 'layers');
    }
    if (!layers.any((l) => l.scale == 1)) {
      json.fail('the strongest layer needs scale 1', 'layers');
    }
    if (layers.map((l) => l.id).toSet().length != layers.length) {
      json.fail('layer ids must differ', 'layers');
    }
    final background = json.number('background');
    if (background < 0 || background >= clear) {
      json.fail('from 0 to below $clear', 'background');
    }
    final spots = [
      for (final s in json.objects('spots'))
        () {
          s.allowOnly({'id', 'labelKey', 'at', 'radius', 'strength'});
          final at = s.numbers('at', length: 2);
          if (at.any((v) => v < 0 || v > 1)) s.fail('from 0 to 1', 'at');
          final radius = s.number('radius');
          if (radius < 0.03 || radius > 0.3) {
            s.fail('from 0.03 to 0.3', 'radius');
          }
          final strength = s.number('strength');
          if (strength <= 0 || strength > 1) {
            s.fail('above 0, up to 1', 'strength');
          }
          return ScanSpot(
            id: s.string('id'),
            labelKey: s.string('labelKey'),
            x: at[0],
            y: at[1],
            radius: radius,
            strength: strength,
          );
        }(),
    ];
    if (spots.isEmpty || spots.length > 6) {
      json.fail('need 1 to 6 spots', 'spots');
    }
    if (spots.map((s) => s.id).toSet().length != spots.length) {
      json.fail('spot ids must differ', 'spots');
    }
    final config = ScanConfig(
      layers: layers,
      spots: spots,
      background: background,
    );
    final top = layers.indexWhere((l) => l.scale == 1);
    for (final (i, s) in spots.indexed) {
      if (config.reading(top, s.x, s.y) < clear) {
        json.fail('reads below $clear at its centre', 'spots[$i]');
      }
    }
    return config;
  }
}

final class ScanLayer {
  const ScanLayer({
    required this.id,
    required this.labelKey,
    required this.scale,
  });

  final String id;
  final String labelKey;
  final double scale;
}

final class ScanSpot {
  const ScanSpot({
    required this.id,
    required this.labelKey,
    required this.x,
    required this.y,
    required this.radius,
    required this.strength,
  });

  final String id;
  final String labelKey;
  final double x;
  final double y;
  final double radius;
  final double strength;

  double distance(double px, double py) =>
      math.sqrt((px - x) * (px - x) + (py - y) * (py - y));
}

final class ScanConfig implements PuzzleConfig {
  ScanConfig({
    required List<ScanLayer> layers,
    required List<ScanSpot> spots,
    required this.background,
  }) : layers = List.unmodifiable(layers),
       spots = List.unmodifiable(spots);

  final List<ScanLayer> layers;
  final List<ScanSpot> spots;
  final double background;

  /// The reading on [layer] at ([x], [y]), from 0 to 1.
  double reading(int layer, double x, double y) {
    var sum = 0.0;
    for (final s in spots) {
      final d = s.distance(x, y) / s.radius;
      sum += s.strength * math.exp(-d * d);
    }
    return math.min(1, background + layers[layer].scale * sum);
  }

  ScanState start() => ScanState(this, 0, const {}, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final l in layers) ContentRef.text(l.labelKey),
    for (final s in spots) ContentRef.text(s.labelKey),
  ];
}

/// What a mark came to.
enum ScanMark { found, again, faint, miss }

final class ScanState {
  ScanState(this.config, this.layer, Set<String> found, this.mistakes)
    : found = Set.unmodifiable(found);

  final ScanConfig config;

  /// The layer laid uppermost.
  final int layer;

  /// Spots found so far.
  final Set<String> found;

  /// Marks made where nothing is.
  final int mistakes;

  bool get isSolved => found.length == config.spots.length;

  double reading(double x, double y) => config.reading(layer, x, y);

  /// Lays [layer] uppermost.
  ScanState show(int layer) => isSolved || layer == this.layer
      ? this
      : ScanState(config, layer, found, mistakes);

  /// What a mark at ([x], [y]) would come to.
  ScanMark judge(double x, double y) {
    ScanSpot? near;
    for (final s in config.spots) {
      final d = s.distance(x, y);
      if (d <= s.radius && (near == null || d < near.distance(x, y))) {
        near = s;
      }
    }
    if (near == null) return ScanMark.miss;
    if (found.contains(near.id)) return ScanMark.again;
    return reading(x, y) >= ScanType.clear ? ScanMark.found : ScanMark.faint;
  }

  /// The spot a mark at ([x], [y]) finds, if any.
  ScanSpot? spotAt(double x, double y) {
    if (judge(x, y) != ScanMark.found) return null;
    return config.spots
        .where((s) => s.distance(x, y) <= s.radius && !found.contains(s.id))
        .reduce((a, b) => a.distance(x, y) <= b.distance(x, y) ? a : b);
  }

  /// Marks the probe's place at ([x], [y]).
  ScanState mark(double x, double y) {
    if (isSolved) return this;
    switch (judge(x, y)) {
      case ScanMark.found:
        return ScanState(config, layer, {...found, spotAt(x, y)!.id}, mistakes);
      case ScanMark.miss:
        return ScanState(config, layer, found, mistakes + 1);
      case ScanMark.again:
      case ScanMark.faint:
        return this;
    }
  }
}
