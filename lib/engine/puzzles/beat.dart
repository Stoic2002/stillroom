import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `beat`: a great bell's rim seen from below, with places to strike it.
/// Struck anywhere, the bell's tone swells and fades (a beat), deeper at
/// some places than at others. Find the place where it swells deepest, and
/// mark it.
///
/// ```json
/// "config": { "swell": [0.2, 0.45, 0.3, 0.55, 0.35, 0.9, 0.4, 0.25] }
/// ```
/// `swell` gives, for each place round the rim (6 to 12, clockwise from
/// the top), how deeply the ring swells and fades there: 0 steady, 1 all
/// the way to silence and back. The deepest must stand out: at least 0.15
/// above every other. Marking any other place is a mistake.
final class BeatType implements PuzzleType {
  const BeatType();

  static const typeId = 'beat';

  /// How far the deepest swell must stand above the rest.
  static const margin = 0.15;

  @override
  String get id => typeId;

  @override
  BeatConfig parseConfig(JsonReader json) {
    json.allowOnly({'swell'});
    final swell = json.numbers('swell');
    if (swell.length < 6 || swell.length > 12) {
      json.fail('need 6 to 12 places', 'swell');
    }
    for (final (i, s) in swell.indexed) {
      if (s < 0 || s > 1) json.fail('from 0 to 1', 'swell[$i]');
    }
    final deepest = swell.indexOf(swell.reduce((a, b) => a > b ? a : b));
    for (final (i, s) in swell.indexed) {
      if (i != deepest && swell[deepest] - s < margin) {
        json.fail(
          'the deepest swell must stand $margin above every other',
          'swell[$i]',
        );
      }
    }
    return BeatConfig(swell: swell, deepest: deepest);
  }
}

final class BeatConfig implements PuzzleConfig {
  BeatConfig({required List<double> swell, required this.deepest})
    : swell = List.unmodifiable(swell);

  final List<double> swell;

  /// The place where the ring swells deepest.
  final int deepest;

  int get places => swell.length;

  BeatState start() => BeatState(this, const {}, null, 0);

  @override
  Iterable<ContentRef> get references => const [];
}

final class BeatState {
  BeatState(this.config, Set<int> struck, this.marked, this.mistakes)
    : struck = Set.unmodifiable(struck);

  final BeatConfig config;

  /// Places struck so far.
  final Set<int> struck;

  /// The place marked, once right.
  final int? marked;

  /// Wrong places marked.
  final int mistakes;

  bool get isSolved => marked != null;

  BeatState strike(int place) =>
      isSolved ? this : BeatState(config, {...struck, place}, marked, mistakes);

  /// Marks [place] as the deepest swell: solved if it is.
  BeatState mark(int place) {
    if (isSolved) return this;
    return place == config.deepest
        ? BeatState(config, {...struck, place}, place, mistakes)
        : BeatState(config, struck, null, mistakes + 1);
  }
}
