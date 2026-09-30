import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `resonance`: a great bell over a hollow in the ground, and a log striker
/// on ropes. Pull the log back and let it swing; the ring runs on as long
/// as the pull was strong and the hollow suits the bell. Dig the hollow
/// deeper or fill it in, and strike again, until the ring runs past the
/// mark.
///
/// ```json
/// "config": { "depths": 5, "start": 0, "right": 3, "mark": 0.8 }
/// ```
/// The hollow has `depths` settings (3 to 8), from shallow (0) to deep; it
/// starts at `start` and suits the bell at `right`. A strike's ring, as a
/// share of the whole trace, is the pull (0.4 at least, or the log barely
/// touches the bronze) times 1 at the right depth, 0.75 one step off, and
/// so on. Solved when a ring reaches `mark` (above 0.75 and at most 1), so
/// only a strong pull over the right hollow will do.
final class ResonanceType implements PuzzleType {
  const ResonanceType();

  static const typeId = 'resonance';

  @override
  String get id => typeId;

  @override
  ResonanceConfig parseConfig(JsonReader json) {
    json.allowOnly({'depths', 'start', 'right', 'mark'});
    final depths = json.integer('depths');
    if (depths < 3 || depths > 8) json.fail('need 3 to 8 depths', 'depths');
    int depth(String key) {
      final d = json.integer(key);
      if (d < 0 || d >= depths) json.fail('a depth 0 to ${depths - 1}', key);
      return d;
    }

    final start = depth('start');
    final right = depth('right');
    if (start == right) json.fail('starts already right', 'start');
    final mark = json.optionalNumber('mark') ?? 0.8;
    if (mark <= ResonanceConfig.offStep || mark > 1) {
      json.fail('above ${ResonanceConfig.offStep} and at most 1', 'mark');
    }
    return ResonanceConfig(
      depths: depths,
      start: start,
      right: right,
      mark: mark,
    );
  }
}

final class ResonanceConfig implements PuzzleConfig {
  const ResonanceConfig({
    required this.depths,
    required this.start,
    required this.right,
    required this.mark,
  });

  /// The most a ring can reach one step off the right depth.
  static const offStep = 0.75;

  /// A pull below this barely touches the bronze.
  static const minPull = 0.4;

  final int depths;
  final int start;
  final int right;
  final double mark;

  /// How well a hollow of [depth] suits the bell, 0 to 1.
  double suits(int depth) =>
      math.max(0, 1 - (1 - offStep) * (depth - right).abs());

  /// The ring of a strike with [pull] (0 to 1) over a hollow of [depth], as
  /// a share of the trace; 0 if the pull is too gentle to ring it.
  double ring(int depth, double pull) {
    if (pull < minPull) return 0;
    return math.min(1, pull) * suits(depth);
  }

  ResonanceState startState() => ResonanceState(this, start, 0, null);

  @override
  Iterable<ContentRef> get references => const [];
}

final class ResonanceState {
  const ResonanceState(this.config, this.depth, this.strikes, this.lastRing);

  final ResonanceConfig config;

  /// The hollow's depth now.
  final int depth;

  /// Strikes so far that rang the bell.
  final int strikes;

  /// The last strike's ring (0 if it barely touched), or null before any.
  final double? lastRing;

  bool get isSolved => (lastRing ?? 0) >= config.mark;

  ResonanceState dig() => isSolved || depth >= config.depths - 1
      ? this
      : ResonanceState(config, depth + 1, strikes, lastRing);

  ResonanceState fill() => isSolved || depth <= 0
      ? this
      : ResonanceState(config, depth - 1, strikes, lastRing);

  /// Lets the log swing into the bell after pulling it back by [pull].
  ResonanceState strike(double pull) {
    if (isSolved) return this;
    final ring = config.ring(depth, pull);
    return ResonanceState(
      config,
      depth,
      ring > 0 ? strikes + 1 : strikes,
      ring,
    );
  }
}
