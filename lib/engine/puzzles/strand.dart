import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `strand`: strands of hair cut into segments, each measured one at a
/// time with little reactor time to spare. Find each strand's highest
/// segment, then say how the readings run along the hair.
///
/// ```json
/// "config": {
///   "strands": [
///     { "readings": [6, 9, 14, 22, 38, 64, 132, 88, 41, 20, 12, 8, 6, 5] }
///   ],
///   "measurements": 7,
///   "curve": "peak"
/// }
/// ```
/// Each strand gives its segments' readings from root to tip (6 to 30,
/// all above 0, one clear highest). A strand allows `measurements`
/// readings; a new sample starts it over. A segment can be marked as the
/// highest once measured; a wrong mark is a mistake. When every strand's
/// highest is found, the player says whether the readings run `steady`
/// along the hair or rise to a `peak`; `curve` is the right answer.
final class StrandType implements PuzzleType {
  const StrandType();

  static const typeId = 'strand';

  @override
  String get id => typeId;

  @override
  StrandConfig parseConfig(JsonReader json) {
    json.allowOnly({'strands', 'measurements', 'curve'});
    final raw = json.objects('strands');
    if (raw.isEmpty || raw.length > 3) {
      json.fail('need 1 to 3 strands', 'strands');
    }
    final strands = <List<double>>[];
    for (final s in raw) {
      s.allowOnly({'readings'});
      final values = s.numbers('readings');
      if (values.length < 6 || values.length > 30) {
        s.fail('need 6 to 30 readings', 'readings');
      }
      for (final (k, v) in values.indexed) {
        if (v <= 0) s.fail('a reading above 0', 'readings[$k]');
      }
      final top = values.reduce((a, b) => a > b ? a : b);
      if (values.where((v) => v == top).length != 1) {
        s.fail('need one clear highest reading', 'readings');
      }
      strands.add(values);
    }
    final measurements = json.integer('measurements');
    final shortest = strands
        .map((s) => s.length)
        .reduce((a, b) => a < b ? a : b);
    if (measurements < 3 || measurements >= shortest) {
      json.fail('need 3 to ${shortest - 1}', 'measurements');
    }
    final curve =
        StrandCurve.values.asNameMap()[json.string('curve')] ??
        json.fail('expected "steady" or "peak"', 'curve');
    return StrandConfig(
      strands: strands,
      measurements: measurements,
      curve: curve,
    );
  }
}

enum StrandCurve { steady, peak }

final class StrandConfig implements PuzzleConfig {
  StrandConfig({
    required List<List<double>> strands,
    required this.measurements,
    required this.curve,
  }) : strands = List.unmodifiable([
         for (final s in strands) List<double>.unmodifiable(s),
       ]);

  final List<List<double>> strands;
  final int measurements;
  final StrandCurve curve;

  /// The highest segment of strand [s].
  int peak(int s) {
    final values = strands[s];
    var best = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[best]) best = i;
    }
    return best;
  }

  StrandState start() => StrandState(
    this,
    measured: [for (final _ in strands) const <int>{}],
    found: [for (final _ in strands) false],
    samples: 0,
    mistakes: 0,
    answered: false,
  );

  @override
  Iterable<ContentRef> get references => const [];
}

final class StrandState {
  StrandState(
    this.config, {
    required List<Set<int>> measured,
    required List<bool> found,
    required this.samples,
    required this.mistakes,
    required this.answered,
  }) : measured = List.unmodifiable([
         for (final m in measured) Set<int>.unmodifiable(m),
       ]),
       found = List.unmodifiable(found);

  final StrandConfig config;

  /// Segments measured so far, per strand, on its current sample.
  final List<Set<int>> measured;

  /// Whether each strand's highest segment has been found.
  final List<bool> found;

  /// New samples taken.
  final int samples;
  final int mistakes;

  /// Whether the curve has been named rightly.
  final bool answered;

  bool get allFound => found.every((f) => f);

  bool get isSolved => answered;

  int left(int s) => found[s] ? 0 : config.measurements - measured[s].length;

  StrandState _with({
    List<Set<int>>? measured,
    List<bool>? found,
    int? samples,
    int? mistakes,
    bool? answered,
  }) => StrandState(
    config,
    measured: measured ?? this.measured,
    found: found ?? this.found,
    samples: samples ?? this.samples,
    mistakes: mistakes ?? this.mistakes,
    answered: answered ?? this.answered,
  );

  /// Measures segment [i] of strand [s], if reactor time is left.
  StrandState measure(int s, int i) {
    if (answered || found[s] || measured[s].contains(i) || left(s) <= 0) {
      return this;
    }
    return _with(
      measured: [
        for (final (k, m) in measured.indexed) k == s ? {...m, i} : m,
      ],
    );
  }

  /// Marks measured segment [i] as strand [s]'s highest.
  StrandState mark(int s, int i) {
    if (answered || found[s] || !measured[s].contains(i)) return this;
    if (i == config.peak(s)) {
      return _with(found: [for (final (k, f) in found.indexed) k == s || f]);
    }
    return _with(mistakes: mistakes + 1);
  }

  /// Starts strand [s] over on a fresh sample.
  StrandState newSample(int s) {
    if (answered || found[s]) return this;
    return _with(
      measured: [for (final (k, m) in measured.indexed) k == s ? <int>{} : m],
      samples: samples + 1,
    );
  }

  /// Names how the readings run along the hair.
  StrandState choose(StrandCurve curve) {
    if (answered || !allFound) return this;
    return curve == config.curve
        ? _with(answered: true)
        : _with(mistakes: mistakes + 1);
  }
}
