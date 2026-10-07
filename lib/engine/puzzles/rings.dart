import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `rings`: a tree-ring core cross-dated against a master chronology. The
/// master gives a ring width for every year from `startYear`; the core
/// gives its own rings, oldest first, with no years. Slide the core along
/// the master until its pattern of wide and narrow rings matches, and
/// check: only the place where it truly matches dates it. Once dated, mark
/// the `run` narrowest rings in a row on the core; their years are the
/// answer.
///
/// ```json
/// "config": {
///   "startYear": 1560,
///   "master": [0.8, 0.6, 0.9],
///   "core": [0.7, 0.3, 0.8],
///   "offset": 21,
///   "run": 3
/// }
/// ```
/// Widths from 0.05 to 1. 12 to 60 master years, 6 to 24 core rings, and
/// `offset` (where the core's first ring falls on the master) leaves the
/// whole core on the master. At `offset` the core matches better than at
/// any other place by a clear margin (`minMargin` in summed difference);
/// `run` (2 to 5) rings in a row there are narrower in sum than any other
/// such run on the core.
final class RingsType implements PuzzleType {
  const RingsType();

  static const typeId = 'rings';

  /// How much worse the next-best place must match than the right one.
  static const minMargin = 0.5;

  @override
  String get id => typeId;

  @override
  RingsConfig parseConfig(JsonReader json) {
    json.allowOnly({'startYear', 'master', 'core', 'offset', 'run'});
    List<double> widths(String key, int least, int most) {
      final list = json.numbers(key);
      if (list.length < least || list.length > most) {
        json.fail('need $least to $most rings', key);
      }
      for (final (i, w) in list.indexed) {
        if (w < 0.05 || w > 1) json.fail('from 0.05 to 1', '$key[$i]');
      }
      return list;
    }

    final master = widths('master', 12, 60);
    final core = widths('core', 6, 24);
    final offset = json.integer('offset');
    if (offset < 0 || offset + core.length > master.length) {
      json.fail('the core must lie on the master', 'offset');
    }
    final run = json.integer('run');
    if (run < 2 || run > 5 || run >= core.length) json.fail('2 to 5', 'run');
    final config = RingsConfig(
      startYear: json.integer('startYear'),
      master: master,
      core: core,
      offset: offset,
      run: run,
    );
    final best = config.mismatch(offset);
    for (var o = 0; o <= config.lastOffset; o++) {
      if (o != offset && config.mismatch(o) < best + minMargin) {
        json.fail('the core matches too well at $o as well', 'offset');
      }
    }
    final narrow = config.runWidth(config.narrowest);
    for (var i = 0; i + run <= core.length; i++) {
      if (i != config.narrowest && config.runWidth(i) <= narrow) {
        json.fail('the narrowest run must be the only one', 'core');
      }
    }
    return config;
  }
}

final class RingsConfig implements PuzzleConfig {
  RingsConfig({
    required this.startYear,
    required List<double> master,
    required List<double> core,
    required this.offset,
    required this.run,
  }) : master = List.unmodifiable(master),
       core = List.unmodifiable(core);

  final int startYear;
  final List<double> master;
  final List<double> core;
  final int offset;
  final int run;

  /// The furthest the core can slide along the master.
  int get lastOffset => master.length - core.length;

  /// How badly the core matches with its first ring at master ring [o]:
  /// the summed difference of widths.
  double mismatch(int o) {
    var sum = 0.0;
    for (var i = 0; i < core.length; i++) {
      sum += (core[i] - master[o + i]).abs();
    }
    return sum;
  }

  double runWidth(int start) {
    var sum = 0.0;
    for (var i = start; i < start + run; i++) {
      sum += core[i];
    }
    return sum;
  }

  /// Where on the core the narrowest run of [run] rings starts.
  int get narrowest {
    var best = 0;
    for (var i = 1; i + run <= core.length; i++) {
      if (runWidth(i) < runWidth(best)) best = i;
    }
    return best;
  }

  /// The year of the core's ring [i], once dated.
  int yearOf(int i) => startYear + offset + i;

  RingsState start() => RingsState(this, 0, 0, dated: false, marked: false);

  @override
  Iterable<ContentRef> get references => const [];
}

final class RingsState {
  const RingsState(
    this.config,
    this.position,
    this.mistakes, {
    required this.dated,
    required this.marked,
  });

  final RingsConfig config;

  /// Where the core's first ring lies on the master now.
  final int position;
  final int mistakes;
  final bool dated;
  final bool marked;

  bool get isSolved => dated && marked;

  /// Slides the core so its first ring lies on master ring [to].
  RingsState slide(int to) {
    if (dated) return this;
    final p = to.clamp(0, config.lastOffset);
    return RingsState(config, p, mistakes, dated: false, marked: false);
  }

  /// Whether the core matches where it lies now.
  bool get fits => position == config.offset;

  /// Checks the match where the core lies: dates it, or a mistake.
  RingsState check() {
    if (dated) return this;
    return fits
        ? RingsState(config, position, mistakes, dated: true, marked: false)
        : RingsState(
            config,
            position,
            mistakes + 1,
            dated: false,
            marked: false,
          );
  }

  /// Marks the run of rings starting at core ring [start] as the
  /// narrowest.
  RingsState mark(int start) {
    if (!dated || marked) return this;
    return start == config.narrowest
        ? RingsState(config, position, mistakes, dated: true, marked: true)
        : RingsState(
            config,
            position,
            mistakes + 1,
            dated: true,
            marked: false,
          );
  }
}
