import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `still`: a copper still over a little furnace, its worm in a tub of
/// cold water. What comes over first (the heads) is sharp and cloudy, the
/// middle (the heart) clear and sweet, the last (the tails) oily and
/// heavy. Feed the fire, keep the water running, and move the glass under
/// the spout as the drip changes: the heart in its own glass, the rest
/// set aside.
///
/// ```json
/// "config": {
///   "heads": 2, "heart": 8, "tails": 3,
///   "rates": [0, 0.8, 2.0],
///   "blur": [0.3, 2.4],
///   "keep": 0.8, "tolerance": 0.6, "dry": 4
/// }
/// ```
/// - `heads`, `heart`, `tails`: how much of each comes over, in measures.
/// - `rates`: measures a second at each heat (none, gentle, fierce); the
///   first must be 0, and they rise.
/// - `blur`: at gentle and at fierce heat, how many measures either side
///   of a cut come over mixed: run it hard and the cuts smear.
/// - `keep`: the share of the heart that must end in the heart's glass.
/// - `tolerance`: measures of heads and tails allowed in the heart's glass.
/// - `dry`: seconds the fire may burn with no water before the worm runs
///   hot and the run is spoiled.
final class StillType implements PuzzleType {
  const StillType();

  static const typeId = 'still';

  @override
  String get id => typeId;

  @override
  StillConfig parseConfig(JsonReader json) {
    json.allowOnly({
      'heads',
      'heart',
      'tails',
      'rates',
      'blur',
      'keep',
      'tolerance',
      'dry',
    });
    double positive(String key) {
      final v = json.number(key);
      if (v <= 0) json.fail('must be above 0', key);
      return v;
    }

    final rates = json.numbers('rates', length: 3);
    if (rates[0] != 0 || rates[1] <= 0 || rates[2] <= rates[1]) {
      json.fail('0, then two rising rates', 'rates');
    }
    final blur = json.numbers('blur', length: 2);
    if (blur[0] < 0 || blur[1] < blur[0]) {
      json.fail('two rising widths from 0', 'blur');
    }
    final keep = json.number('keep');
    if (keep <= 0 || keep > 1) json.fail('above 0 and up to 1', 'keep');
    return StillConfig(
      heads: positive('heads'),
      heart: positive('heart'),
      tails: positive('tails'),
      rates: rates,
      blur: blur,
      keep: keep,
      tolerance: json.number('tolerance'),
      dry: positive('dry'),
    );
  }
}

final class StillConfig implements PuzzleConfig {
  StillConfig({
    required this.heads,
    required this.heart,
    required this.tails,
    required List<double> rates,
    required List<double> blur,
    required this.keep,
    required this.tolerance,
    required this.dry,
  }) : rates = List.unmodifiable(rates),
       blur = List.unmodifiable(blur);

  final double heads;
  final double heart;
  final double tails;
  final List<double> rates;
  final List<double> blur;
  final double keep;
  final double tolerance;
  final double dry;

  double get total => heads + heart + tails;

  StillState start() => StillState(this);

  @override
  Iterable<ContentRef> get references => const [];
}

/// The three cuts of a run, and the glasses that catch them.
enum Cut { heads, heart, tails }

/// What is in one glass, by cut.
final class Glass {
  const Glass([this.heads = 0, this.heart = 0, this.tails = 0]);

  final double heads;
  final double heart;
  final double tails;

  double get total => heads + heart + tails;

  Glass add(double h, double m, double t) =>
      Glass(heads + h, heart + m, tails + t);
}

/// How a run ended.
enum StillEnd { running, kept, spoiled, lost }

final class StillState {
  StillState(
    this.config, {
    this.run = 0,
    this.heat = 0,
    this.water = false,
    this.receiver = Cut.heads,
    List<Glass> glasses = const [Glass(), Glass(), Glass()],
    this.hot = 0,
    this.end = StillEnd.running,
  }) : glasses = List.unmodifiable(glasses);

  final StillConfig config;

  /// Measures come over so far.
  final double run;

  /// 0 no fire, 1 gentle, 2 fierce.
  final int heat;

  /// The cold water running through the tub.
  final bool water;

  /// The glass under the spout.
  final Cut receiver;

  /// The three glasses, by [Cut].
  final List<Glass> glasses;

  /// Seconds the fire has burned with no water.
  final double hot;
  final StillEnd end;

  bool get isSolved => end == StillEnd.kept;

  StillState _copy({
    double? run,
    int? heat,
    bool? water,
    Cut? receiver,
    List<Glass>? glasses,
    double? hot,
    StillEnd? end,
  }) => StillState(
    config,
    run: run ?? this.run,
    heat: heat ?? this.heat,
    water: water ?? this.water,
    receiver: receiver ?? this.receiver,
    glasses: glasses ?? this.glasses,
    hot: hot ?? this.hot,
    end: end ?? this.end,
  );

  StillState setHeat(int level) =>
      end == StillEnd.running ? _copy(heat: level.clamp(0, 2)) : this;

  StillState setWater(bool on) =>
      end == StillEnd.running ? _copy(water: on, hot: on ? 0 : hot) : this;

  StillState moveGlass(Cut to) =>
      end == StillEnd.running ? _copy(receiver: to) : this;

  /// Empties the glasses and puts the still back to the start.
  StillState reset() => StillState(config);

  /// The share of heads, heart and tails coming over at [at] measures,
  /// with the cuts smeared [width] measures wide.
  (double, double, double) mixAt(double at, double width) {
    final c1 = config.heads;
    final c2 = config.heads + config.heart;
    double ramp(double x) =>
        width <= 0 ? (x > 0 ? 1.0 : 0.0) : ((x / width) + 0.5).clamp(0.0, 1.0);
    final heads = 1 - ramp(at - c1);
    final tails = ramp(at - c2);
    return (heads, math.max(0, 1 - heads - tails), tails);
  }

  /// What is dripping now: the cut that makes most of it.
  Cut get dripping {
    final (h, m, t) = mixAt(run, config.blur[math.max(0, heat - 1)]);
    if (h >= m && h >= t) return Cut.heads;
    return m >= t ? Cut.heart : Cut.tails;
  }

  /// Runs the still [dt] seconds.
  StillState tick(double dt) {
    if (end != StillEnd.running || heat == 0) return this;
    if (!water) {
      final nextHot = hot + dt;
      return nextHot >= config.dry
          ? _copy(hot: nextHot, end: StillEnd.spoiled)
          : _copy(hot: nextHot);
    }
    final amount = math.min(config.rates[heat] * dt, config.total - run);
    final width = config.blur[heat - 1];
    // Integrate the mix over the amount in small steps.
    const steps = 4;
    var h = 0.0, m = 0.0, t = 0.0;
    for (var k = 0; k < steps; k++) {
      final at = run + amount * (k + 0.5) / steps;
      final (a, b, c) = mixAt(at, width);
      h += a * amount / steps;
      m += b * amount / steps;
      t += c * amount / steps;
    }
    final glasses = [
      for (final cut in Cut.values)
        cut == receiver
            ? this.glasses[cut.index].add(h, m, t)
            : this.glasses[cut.index],
    ];
    final next = run + amount;
    if (next < config.total - 1e-9) {
      return _copy(run: next, glasses: glasses);
    }
    return _copy(run: config.total, glasses: glasses, end: _judge(glasses));
  }

  StillEnd _judge(List<Glass> glasses) {
    final heart = glasses[Cut.heart.index];
    final kept = heart.heart >= config.keep * config.heart - 1e-9;
    final clean = heart.heads + heart.tails <= config.tolerance + 1e-9;
    return kept && clean ? StillEnd.kept : StillEnd.lost;
  }
}
