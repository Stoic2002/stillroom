import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `courses`: a breach in a dry-stone wall and the fallen blocks. Lay them
/// back course by course, left to right, no mortar: each course must fill
/// the gap exactly, and no joint may sit over a joint in the course below.
/// Then the chevron band on top: thin slabs, each leaning left or right,
/// turned until they lean in turn and the zigzag runs true.
///
/// ```json
/// "config": {
///   "width": 12,
///   "base": [3, 4, 2, 3],
///   "courses": 3,
///   "blocks": [4, 2, 4, 4, 2, 4, 4, 2, 4, 2, 4],
///   "chevrons": [true, true, false, true, false, false, true, false]
/// }
/// ```
/// `width` is the gap in block units (4 to 16); `base` the course still
/// standing below it, block lengths summing to `width`. `blocks` is the
/// pile, every length from 1 to `width`, summing to `width` times
/// `courses` (1 to 5). `chevrons` gives each slab's lean at the start
/// (`true` leans right; 4 to 16 slabs, not already alternating). The pile
/// must be layable.
final class CoursesType implements PuzzleType {
  const CoursesType();

  static const typeId = 'courses';

  @override
  String get id => typeId;

  @override
  CoursesConfig parseConfig(JsonReader json) {
    json.allowOnly({'width', 'base', 'courses', 'blocks', 'chevrons'});
    final width = json.integer('width');
    if (width < 4 || width > 16) json.fail('from 4 to 16', 'width');
    List<int> lengths(String key) {
      final values = json.numbers(key);
      return [
        for (final (k, v) in values.indexed)
          if (v != v.roundToDouble() || v < 1 || v > width)
            json.fail('a whole length from 1 to $width', '$key[$k]')
          else
            v.toInt(),
      ];
    }

    final base = lengths('base');
    if (base.fold(0, (a, b) => a + b) != width) {
      json.fail('must sum to $width', 'base');
    }
    final courses = json.integer('courses');
    if (courses < 1 || courses > 5) json.fail('from 1 to 5', 'courses');
    final blocks = lengths('blocks');
    if (blocks.fold(0, (a, b) => a + b) != width * courses) {
      json.fail('must sum to ${width * courses}', 'blocks');
    }
    final raw = json.value('chevrons');
    if (raw is! List || raw.any((v) => v is! bool)) {
      json.fail('expected a list of true or false', 'chevrons');
    }
    final chevrons = raw.cast<bool>();
    if (chevrons.length < 4 || chevrons.length > 16) {
      json.fail('need 4 to 16 slabs', 'chevrons');
    }
    final config = CoursesConfig(
      width: width,
      base: base,
      courses: courses,
      blocks: blocks,
      chevrons: chevrons,
    );
    if (CoursesConfig.alternates(chevrons)) {
      json.fail('already alternating', 'chevrons');
    }
    if (config.solution() == null) json.fail('cannot be laid', 'blocks');
    return config;
  }
}

final class CoursesConfig implements PuzzleConfig {
  CoursesConfig({
    required this.width,
    required List<int> base,
    required this.courses,
    required List<int> blocks,
    required List<bool> chevrons,
  }) : base = List.unmodifiable(base),
       blocks = List.unmodifiable(blocks),
       chevrons = List.unmodifiable(chevrons);

  final int width;

  /// The course still standing under the gap, as block lengths.
  final List<int> base;

  /// How many courses to lay.
  final int courses;

  /// The fallen pile's lengths.
  final List<int> blocks;

  /// Each chevron slab's lean at the start: `true` leans right.
  final List<bool> chevrons;

  /// The joints inside a course of [lengths]: where one block meets the
  /// next, measured from the left.
  static Set<int> joints(Iterable<int> lengths) {
    final out = <int>{};
    var at = 0;
    for (final l in lengths) {
      at += l;
      out.add(at);
    }
    return out..remove(at);
  }

  static bool alternates(List<bool> leans) => [
    for (var k = 0; k + 1 < leans.length; k++) leans[k] != leans[k + 1],
  ].every((v) => v);

  /// One way to lay the pile, as block indices per course, or null.
  List<List<int>>? solution() {
    final used = List.filled(blocks.length, false);
    final laid = <List<int>>[];
    bool course(Set<int> below, List<int> current, int at) {
      if (at == width) {
        laid.add([...current]);
        if (laid.length == courses ||
            course(joints([for (final i in current) blocks[i]]), [], 0)) {
          return true;
        }
        laid.removeLast();
        return false;
      }
      final tried = <int>{};
      for (var i = 0; i < blocks.length; i++) {
        final next = at + blocks[i];
        if (used[i] || !tried.add(blocks[i]) || next > width) continue;
        if (next < width && below.contains(next)) continue;
        used[i] = true;
        current.add(i);
        if (course(below, current, next)) return true;
        current.removeLast();
        used[i] = false;
      }
      return false;
    }

    return course(joints(base), [], 0) ? laid : null;
  }

  CoursesState start() => CoursesState(this, const [], chevrons, 0);

  @override
  Iterable<ContentRef> get references => const [];
}

/// What laying a block came to.
enum CoursesLay { laid, tooLong, joint, none }

final class CoursesState {
  CoursesState(
    this.config,
    List<List<int>> laid,
    List<bool> leans,
    this.mistakes,
  ) : laid = List.unmodifiable([
        for (final c in laid) List<int>.unmodifiable(c),
      ]),
      leans = List.unmodifiable(leans);

  final CoursesConfig config;

  /// Block indices laid so far, course by course from the bottom; the last
  /// course may be unfinished.
  final List<List<int>> laid;

  /// Each chevron slab's lean: `true` leans right.
  final List<bool> leans;
  final int mistakes;

  int _length(List<int> course) =>
      course.fold(0, (sum, i) => sum + config.blocks[i]);

  bool get coursesDone =>
      laid.length == config.courses &&
      laid.every((c) => _length(c) == config.width);

  bool get isSolved => coursesDone && CoursesConfig.alternates(leans);

  bool isUsed(int block) => laid.any((c) => c.contains(block));

  /// The course being laid now (0 is the lowest).
  int get current => laid.isEmpty || _length(laid.last) == config.width
      ? laid.length
      : laid.length - 1;

  /// How far along the current course is filled.
  int get filled => current < laid.length ? _length(laid[current]) : 0;

  /// The joints of the course under the current one.
  Set<int> get below => CoursesConfig.joints(
    current == 0
        ? config.base
        : [for (final i in laid[current - 1]) config.blocks[i]],
  );

  /// What laying [block] next in the current course would come to.
  CoursesLay judge(int block) {
    if (coursesDone || isUsed(block)) return CoursesLay.none;
    final next = filled + config.blocks[block];
    if (next > config.width) return CoursesLay.tooLong;
    if (next < config.width && below.contains(next)) return CoursesLay.joint;
    return CoursesLay.laid;
  }

  /// Lays [block] next in the current course, if it fits.
  CoursesState lay(int block) {
    switch (judge(block)) {
      case CoursesLay.none:
        return this;
      case CoursesLay.tooLong || CoursesLay.joint:
        return CoursesState(config, laid, leans, mistakes + 1);
      case CoursesLay.laid:
        final next = [for (final c in laid) c];
        if (current == laid.length) {
          next.add([block]);
        } else {
          next[current] = [...laid[current], block];
        }
        return CoursesState(config, next, leans, mistakes);
    }
  }

  /// Takes back the last block laid.
  CoursesState takeBack() {
    if (isSolved || laid.isEmpty) return this;
    final next = [for (final c in laid) c];
    final last = next.removeLast();
    if (last.length > 1) next.add(last.sublist(0, last.length - 1));
    return CoursesState(config, next, leans, mistakes);
  }

  /// Turns chevron slab [k] to lean the other way, once the courses are
  /// laid.
  CoursesState tilt(int k) {
    if (!coursesDone || isSolved) return this;
    return CoursesState(config, laid, [
      for (final (i, l) in leans.indexed) i == k ? !l : l,
    ], mistakes);
  }
}
