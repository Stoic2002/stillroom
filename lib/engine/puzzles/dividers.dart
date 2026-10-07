import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `dividers`: a chart, its scale of miles, and a pair of dividers. Open
/// the dividers to a span on the scale, pick a heading (a point of the
/// compass, from true north; the chart's own north need not be up), and
/// walk them from the `origin` step by step; mark where they stand. Each
/// target's clue names a place by distance and bearing; marking within
/// `tolerance` miles of it finds it, and the next clue follows.
///
/// ```json
/// "config": {
///   "milesAcross": 120,
///   "aspect": 0.6,
///   "north": 90,
///   "origin": [0.62, 0.8],
///   "spans": [5, 10, 25],
///   "tolerance": 6,
///   "places": [ { "labelKey": "ep.place.croatoan", "at": [0.2, 0.8] } ],
///   "targets": [ { "clueKey": "ep.dividers.croatoan", "place": 0 } ]
/// }
/// ```
/// Positions run 0 to 1 across the chart and down it; the chart is
/// `aspect` as tall as it is wide and `milesAcross` miles wide. `north` is
/// where north points on the chart, in degrees clockwise from up. 1 to 4
/// spans (miles), 2 to 10 places, 1 to 4 targets, each a different place
/// that a whole number of steps (1 to [DividersType.maxSteps]) of one span
/// on one of the eight headings reaches within `tolerance`.
final class DividersType implements PuzzleType {
  const DividersType();

  static const typeId = 'dividers';
  static const maxSteps = 15;

  @override
  String get id => typeId;

  @override
  DividersConfig parseConfig(JsonReader json) {
    json.allowOnly({
      'milesAcross',
      'aspect',
      'north',
      'origin',
      'spans',
      'tolerance',
      'places',
      'targets',
    });
    math.Point<double> point(JsonReader r, String key) {
      final p = r.numbers(key, length: 2);
      if (p.any((v) => v < 0 || v > 1)) r.fail('from 0 to 1', key);
      return math.Point(p[0], p[1]);
    }

    final spans = json.numbers('spans');
    if (spans.isEmpty || spans.length > 4 || spans.any((s) => s <= 0)) {
      json.fail('1 to 4 spans above 0', 'spans');
    }
    final places = [
      for (final p in json.objects('places'))
        () {
          p.allowOnly({'labelKey', 'at'});
          return DividersPlace(
            labelKey: p.string('labelKey'),
            at: point(p, 'at'),
          );
        }(),
    ];
    if (places.length < 2 || places.length > 10) {
      json.fail('need 2 to 10 places', 'places');
    }
    final targets = [
      for (final t in json.objects('targets'))
        () {
          t.allowOnly({'clueKey', 'place'});
          final place = t.integer('place');
          if (place < 0 || place >= places.length) {
            t.fail('not a place', 'place');
          }
          return DividersTarget(clueKey: t.string('clueKey'), place: place);
        }(),
    ];
    if (targets.isEmpty || targets.length > 4) {
      json.fail('need 1 to 4 targets', 'targets');
    }
    if (targets.map((t) => t.place).toSet().length != targets.length) {
      json.fail('each target a different place', 'targets');
    }
    final config = DividersConfig(
      milesAcross: json.number('milesAcross'),
      aspect: json.number('aspect'),
      north: json.number('north'),
      origin: point(json, 'origin'),
      spans: spans,
      tolerance: json.number('tolerance'),
      places: places,
      targets: targets,
    );
    for (final (i, t) in targets.indexed) {
      if (config.walkTo(t.place) == null) {
        json.fail('no walk of the dividers reaches it', 'targets[$i]');
      }
    }
    return config;
  }
}

final class DividersPlace {
  const DividersPlace({required this.labelKey, required this.at});

  final String labelKey;

  /// On the chart, 0 to 1 across and down.
  final math.Point<double> at;
}

final class DividersTarget {
  const DividersTarget({required this.clueKey, required this.place});

  final String clueKey;
  final int place;
}

/// The eight points of the compass, clockwise from north.
enum Heading { n, ne, e, se, s, sw, w, nw }

final class DividersConfig implements PuzzleConfig {
  DividersConfig({
    required this.milesAcross,
    required this.aspect,
    required this.north,
    required this.origin,
    required List<double> spans,
    required this.tolerance,
    required List<DividersPlace> places,
    required List<DividersTarget> targets,
  }) : spans = List.unmodifiable(spans),
       places = List.unmodifiable(places),
       targets = List.unmodifiable(targets);

  final double milesAcross;
  final double aspect;
  final double north;
  final math.Point<double> origin;
  final List<double> spans;
  final double tolerance;
  final List<DividersPlace> places;
  final List<DividersTarget> targets;

  /// A chart position in miles from its top left.
  math.Point<double> toMiles(math.Point<double> p) =>
      math.Point(p.x * milesAcross, p.y * milesAcross * aspect);

  math.Point<double> fromMiles(math.Point<double> m) =>
      math.Point(m.x / milesAcross, m.y / (milesAcross * aspect));

  /// One mile on [heading], as a move on the chart in miles.
  math.Point<double> unit(Heading heading) {
    final a = (north + heading.index * 45) * math.pi / 180;
    return math.Point(math.sin(a), -math.cos(a));
  }

  /// Where the dividers stand after [steps] of [span] miles on [heading].
  math.Point<double> standAt(double span, Heading heading, int steps) =>
      fromMiles(toMiles(origin) + unit(heading) * (span * steps));

  /// Miles between two chart positions.
  double miles(math.Point<double> a, math.Point<double> b) =>
      toMiles(a).distanceTo(toMiles(b));

  /// A walk that reaches place [i], if there is one.
  (double, Heading, int)? walkTo(int i) {
    for (final span in spans) {
      for (final h in Heading.values) {
        for (var k = 1; k <= DividersType.maxSteps; k++) {
          if (miles(standAt(span, h, k), places[i].at) <= tolerance) {
            return (span, h, k);
          }
        }
      }
    }
    return null;
  }

  DividersState start() => DividersState(this, null, null, 0, 0, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final p in places) ContentRef.text(p.labelKey),
    for (final t in targets) ContentRef.text(t.clueKey),
  ];
}

/// What marking where the dividers stand came to.
enum DividersMark { found, elsewhere, nothing, unset }

final class DividersState {
  const DividersState(
    this.config,
    this.span,
    this.heading,
    this.steps,
    this.found,
    this.mistakes,
  );

  final DividersConfig config;

  /// The span set (miles), and the heading picked, if any.
  final double? span;
  final Heading? heading;
  final int steps;

  /// Targets found so far, in order.
  final int found;
  final int mistakes;

  bool get isSolved => found == config.targets.length;

  DividersTarget? get current => isSolved ? null : config.targets[found];

  /// Where the dividers stand now on the chart.
  math.Point<double> get standing {
    final s = span;
    final h = heading;
    if (s == null || h == null) return config.origin;
    return config.standAt(s, h, steps);
  }

  /// Opens the dividers to [miles]; the walk starts again.
  DividersState setSpan(double miles) =>
      DividersState(config, miles, heading, 0, found, mistakes);

  /// Turns to [h]; the walk starts again.
  DividersState setHeading(Heading h) =>
      DividersState(config, span, h, 0, found, mistakes);

  DividersState step() => span == null || heading == null
      ? this
      : DividersState(
          config,
          span,
          heading,
          math.min(steps + 1, DividersType.maxSteps),
          found,
          mistakes,
        );

  DividersState back() => DividersState(
    config,
    span,
    heading,
    math.max(0, steps - 1),
    found,
    mistakes,
  );

  /// What marking here would come to.
  DividersMark judge() {
    final t = current;
    if (t == null || steps == 0) return DividersMark.unset;
    final here = standing;
    if (config.miles(here, config.places[t.place].at) <= config.tolerance) {
      return DividersMark.found;
    }
    for (final p in config.places) {
      if (config.miles(here, p.at) <= config.tolerance) {
        return DividersMark.elsewhere;
      }
    }
    return DividersMark.nothing;
  }

  /// Marks where the dividers stand for the current clue.
  DividersState mark() => switch (judge()) {
    DividersMark.found => DividersState(
      config,
      span,
      heading,
      0,
      found + 1,
      mistakes,
    ),
    DividersMark.elsewhere || DividersMark.nothing => DividersState(
      config,
      span,
      heading,
      steps,
      found,
      mistakes + 1,
    ),
    DividersMark.unset => this,
  };
}
