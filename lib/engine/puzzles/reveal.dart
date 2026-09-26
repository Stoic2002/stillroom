import 'dart:typed_data';

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
import 'puzzle_type.dart';

/// How a [RevealType] surface gives way under the finger.
enum RevealStyle {
  /// Wiping fog, dust, or ash off something.
  wipe,

  /// Shading paper with a pencil until pressed-in writing shows.
  rub,
}

/// `reveal`: drag a finger over a surface to uncover what is under it.
///
/// ```json
/// "config": {
///   "style": "wipe",
///   "hidden": "images/objects/whitechapel_1888/fog_writing.png",
///   "cover": "images/objects/whitechapel_1888/fog.png",
///   "area": [0.2, 0.2, 0.6, 0.5],
///   "threshold": 0.7,
///   "brush": 0.05
/// }
/// ```
/// - `hidden` is what shows through; `cover` (optional) the surface on
///   top. Without `cover`, the style draws one (fog, or blank paper).
/// - `area` is where the hidden thing is; only it counts. Solved when
///   `threshold` of it (0–1, default 0.7) is uncovered.
/// - `brush` is the finger's radius as a share of the board's width
///   (default 0.05).
final class RevealType implements PuzzleType {
  const RevealType();

  static const typeId = 'reveal';

  @override
  String get id => typeId;

  @override
  RevealConfig parseConfig(JsonReader json) {
    json.allowOnly({'style', 'hidden', 'cover', 'area', 'threshold', 'brush'});
    final styleName = json.string('style');
    final style =
        RevealStyle.values.asNameMap()[styleName] ??
        json.fail('expected wipe or rub', 'style');
    final threshold = json.optionalNumber('threshold') ?? 0.7;
    if (threshold <= 0 || threshold > 1) {
      json.fail('must be above 0 and at most 1', 'threshold');
    }
    final brush = json.optionalNumber('brush') ?? 0.05;
    if (brush <= 0 || brush > 0.5) {
      json.fail('must be above 0 and at most 0.5', 'brush');
    }
    return RevealConfig(
      style: style,
      hidden: json.string('hidden'),
      cover: json.optionalString('cover'),
      area: NormalizedRect.fromJson(json, 'area'),
      threshold: threshold,
      brush: brush,
    );
  }
}

final class RevealConfig implements PuzzleConfig {
  const RevealConfig({
    required this.style,
    required this.hidden,
    required this.area,
    this.cover,
    this.threshold = 0.7,
    this.brush = 0.05,
  });

  final RevealStyle style;
  final String hidden;
  final String? cover;
  final NormalizedRect area;
  final double threshold;
  final double brush;

  /// The surface is tracked as a grid of this many cells.
  static const columns = 64;
  static const rows = 36;

  RevealState start() =>
      RevealState(this, Uint8List(columns * rows), uncoveredInArea: 0);

  /// Number of grid cells inside [area].
  int get cellsInArea {
    var count = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns; c++) {
        if (_inArea(c, r)) count++;
      }
    }
    return count;
  }

  bool _inArea(int column, int row) =>
      area.contains((column + 0.5) / columns, (row + 0.5) / rows);

  @override
  Iterable<ContentRef> get references => [
    ContentRef.image(hidden),
    if (cover case final cover?) ContentRef.image(cover),
  ];
}

/// Which cells of the surface are uncovered.
final class RevealState {
  RevealState(this.config, this._cells, {required this.uncoveredInArea});

  final RevealConfig config;
  final Uint8List _cells;

  final int uncoveredInArea;

  bool isUncovered(int column, int row) =>
      _cells[row * RevealConfig.columns + column] != 0;

  /// Share of the area uncovered, 0–1.
  double get progress {
    final total = config.cellsInArea;
    return total == 0 ? 1 : uncoveredInArea / total;
  }

  bool get isSolved => progress >= config.threshold;

  /// The finger passes over the normalized point ([x], [y]) on a board whose
  /// width is [aspect] times its height (so the brush stays round).
  RevealState stroke(double x, double y, {required double aspect}) {
    const columns = RevealConfig.columns;
    const rows = RevealConfig.rows;
    final rx = config.brush;
    final ry = config.brush * aspect;
    Uint8List? cells;
    var added = 0;
    final c0 = ((x - rx) * columns).floor().clamp(0, columns - 1);
    final c1 = ((x + rx) * columns).ceil().clamp(0, columns - 1);
    final r0 = ((y - ry) * rows).floor().clamp(0, rows - 1);
    final r1 = ((y + ry) * rows).ceil().clamp(0, rows - 1);
    for (var r = r0; r <= r1; r++) {
      for (var c = c0; c <= c1; c++) {
        final dx = ((c + 0.5) / columns - x) / rx;
        final dy = ((r + 0.5) / rows - y) / ry;
        if (dx * dx + dy * dy > 1) continue;
        final index = r * columns + c;
        if (_cells[index] != 0) continue;
        (cells ??= Uint8List.fromList(_cells))[index] = 1;
        if (config._inArea(c, r)) added++;
      }
    }
    if (cells == null) return this;
    return RevealState(config, cells, uncoveredInArea: uncoveredInArea + added);
  }

  /// Everything uncovered (once solved, the rest of the surface clears).
  RevealState uncoverAll() {
    final cells = Uint8List(_cells.length)..fillRange(0, _cells.length, 1);
    return RevealState(config, cells, uncoveredInArea: config.cellsInArea);
  }
}
