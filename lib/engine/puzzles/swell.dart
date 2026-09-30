import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `swell`: go down a flight of steps to the sea between the waves. The
/// waves come one after another in a set pattern, some reaching only the
/// lowest step, and now and then a great sea that covers them all. Caught
/// by a wave, the player is driven back to the top.
///
/// ```json
/// "config": {
///   "steps": 6,
///   "stepSeconds": 0.6,
///   "interval": 2.2,
///   "pattern": [2, 1, 3, 2, 6, 1, 1, 2]
/// }
/// ```
/// The player stands on step 0 (the top) and goes down one step per tap, at
/// most one every `stepSeconds` (default 0.6). Step `steps` is the bottom:
/// reaching it solves the puzzle. A wave breaks every `interval` seconds
/// (default 2.2), the first one `interval` seconds in; its reach, how many
/// steps from the bottom it covers, comes from `pattern` in turn, looping.
/// A wave that covers the step the player is on sends them back to the top.
final class SwellType implements PuzzleType {
  const SwellType();

  static const typeId = 'swell';

  @override
  String get id => typeId;

  @override
  SwellConfig parseConfig(JsonReader json) {
    json.allowOnly({'steps', 'stepSeconds', 'interval', 'pattern'});
    final steps = json.integer('steps');
    if (steps < 2 || steps > 12) json.fail('must be 2–12', 'steps');
    final stepSeconds = json.optionalNumber('stepSeconds') ?? 0.6;
    if (stepSeconds <= 0 || stepSeconds > 5) {
      json.fail('must be above 0, at most 5', 'stepSeconds');
    }
    final interval = json.optionalNumber('interval') ?? 2.2;
    if (interval < 0.5 || interval > 20) {
      json.fail('must be 0.5–20 seconds', 'interval');
    }
    final pattern = [
      for (final v in json.numbers('pattern'))
        if (v == v.roundToDouble())
          v.toInt()
        else
          json.fail('must be whole numbers', 'pattern'),
    ];
    if (pattern.isEmpty) json.fail('need at least one wave', 'pattern');
    for (final (i, reach) in pattern.indexed) {
      if (reach < 1 || reach > steps) {
        json.fail('must be 1–steps', 'pattern[$i]');
      }
    }
    return SwellConfig(
      steps: steps,
      stepSeconds: stepSeconds,
      interval: interval,
      pattern: pattern,
    );
  }
}

final class SwellConfig implements PuzzleConfig {
  SwellConfig({
    required this.steps,
    required this.stepSeconds,
    required this.interval,
    required List<int> pattern,
  }) : pattern = List.unmodifiable(pattern);

  final int steps;
  final double stepSeconds;
  final double interval;

  /// How many steps from the bottom each wave covers, in turn.
  final List<int> pattern;

  SwellState start() => SwellState(this, time: 0, position: 0, waves: 0);

  /// When wave [index] (from 0) breaks, in seconds.
  double breakTime(int index) => (index + 1) * interval;

  /// How many steps from the bottom wave [index] covers.
  int reach(int index) => pattern[index % pattern.length];

  /// Whether wave [index] is a great sea, covering every step.
  bool isGreat(int index) => reach(index) >= steps;

  /// Whether a wave of [reach] covers step [position].
  bool covers(int reach, int position) => position > steps - reach;

  /// The next wave to break after [seconds].
  int nextWave(double seconds) => (seconds / interval).floor();

  @override
  Iterable<ContentRef> get references => const [];
}

/// A wave that broke: which one, how far it reached, and whether it caught
/// the player.
typedef SwellBreak = ({int index, int reach, bool caught});

final class SwellState {
  const SwellState(
    this.config, {
    required this.time,
    required this.position,
    required this.waves,
    this.lastStepAt,
    this.caught = 0,
    this.lastBreak,
  });

  final SwellConfig config;

  /// Seconds since the puzzle opened, as far as the state has run.
  final double time;

  /// The step the player is on: 0 at the top, `steps` at the bottom.
  final int position;

  /// How many waves have broken so far.
  final int waves;
  final double? lastStepAt;

  /// How many times a wave has caught the player.
  final int caught;
  final SwellBreak? lastBreak;

  bool get isSolved => position >= config.steps;

  SwellState _copy({
    double? time,
    int? position,
    int? waves,
    double? lastStepAt,
    int? caught,
    SwellBreak? lastBreak,
  }) => SwellState(
    config,
    time: time ?? this.time,
    position: position ?? this.position,
    waves: waves ?? this.waves,
    lastStepAt: lastStepAt ?? this.lastStepAt,
    caught: caught ?? this.caught,
    lastBreak: lastBreak ?? this.lastBreak,
  );

  /// Runs time on to [now], breaking every wave due on the way.
  SwellState advance(double now) {
    if (isSolved || now <= time) return this;
    var state = this;
    while (config.breakTime(state.waves) <= now) {
      final index = state.waves;
      final reach = config.reach(index);
      final caught = config.covers(reach, state.position);
      state = state._copy(
        waves: index + 1,
        position: caught ? 0 : state.position,
        caught: state.caught + (caught ? 1 : 0),
        lastBreak: (index: index, reach: reach, caught: caught),
      );
    }
    return state._copy(time: now);
  }

  /// The player goes down one step at [now], if a step is not already under
  /// way. Waves due before [now] break first.
  SwellState stepDown(double now) {
    final state = advance(now);
    if (state.isSolved) return state;
    final last = state.lastStepAt;
    if (last != null && now - last < config.stepSeconds - 1e-9) return state;
    return state._copy(position: state.position + 1, lastStepAt: now);
  }
}
