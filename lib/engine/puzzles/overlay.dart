import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
import 'puzzle_type.dart';

/// `overlay`: stack see-through sheets (tracing paper, glass negatives,
/// stencils) until their lines meet in one picture.
///
/// ```json
/// "config": {
///   "sheets": [
///     { "id": "boat", "image": "images/...", "rect": [0.3, 0.12, 0.4, 0.72],
///       "from": [0.03, 0.2], "turns": 1 }
///   ],
///   "snap": 0.035
/// }
/// ```
/// Each sheet belongs at `rect` (its size and final place on the board). It
/// starts with its top-left corner at `from` (default: where it belongs),
/// turned `turns` quarter turns clockwise (default 0). The player drags
/// sheets and taps one to turn it a quarter. A sheet let go within `snap`
/// (a share of the board, default 0.035) of its place, the right way up,
/// settles there and stays. Solved when every sheet is in place.
final class OverlayType implements PuzzleType {
  const OverlayType();

  static const typeId = 'overlay';

  @override
  String get id => typeId;

  @override
  OverlayConfig parseConfig(JsonReader json) {
    json.allowOnly({'sheets', 'snap'});
    final sheets = [
      for (final s in json.objects('sheets')) OverlaySheet.fromJson(s),
    ];
    if (sheets.isEmpty) json.fail('needs at least one sheet', 'sheets');
    final seen = <String>{};
    for (final s in sheets) {
      if (!seen.add(s.id)) json.fail('duplicate id "${s.id}"', 'sheets');
    }
    final snap = json.optionalNumber('snap') ?? 0.035;
    if (snap <= 0 || snap > 0.2) {
      json.fail('must be above 0 and at most 0.2', 'snap');
    }
    final config = OverlayConfig(sheets: sheets, snap: snap);
    if (config.start().isSolved) {
      json.fail('every sheet starts in place: nothing to do', 'sheets');
    }
    return config;
  }
}

final class OverlaySheet {
  const OverlaySheet({
    required this.id,
    required this.image,
    required this.rect,
    required this.fromX,
    required this.fromY,
    this.turns = 0,
  });

  factory OverlaySheet.fromJson(JsonReader json) {
    json.allowOnly({'id', 'image', 'rect', 'from', 'turns'});
    final rect = NormalizedRect.fromJson(json, 'rect');
    final from = json.has('from')
        ? json.numbers('from', length: 2)
        : [rect.x, rect.y];
    final turns = json.optionalInt('turns') ?? 0;
    if (turns < 0 || turns > 3) json.fail('must be 0 to 3', 'turns');
    return OverlaySheet(
      id: json.string('id'),
      image: json.string('image'),
      rect: rect,
      fromX: from[0],
      fromY: from[1],
      turns: turns,
    );
  }

  final String id;
  final String image;

  /// Where it belongs, and its size, on the board.
  final NormalizedRect rect;
  final double fromX;
  final double fromY;

  /// Quarter turns clockwise at the start.
  final int turns;
}

final class OverlayConfig implements PuzzleConfig {
  const OverlayConfig({required this.sheets, this.snap = 0.035});

  final List<OverlaySheet> sheets;
  final double snap;

  OverlayPuzzleState start() => OverlayPuzzleState(this, {
    for (final s in sheets) s.id: SheetPlace(s.fromX, s.fromY, s.turns),
  });

  @override
  Iterable<ContentRef> get references => [
    for (final s in sheets) ContentRef.image(s.image),
  ];
}

/// Where one sheet lies: its top-left corner (normalized) and quarter turns.
final class SheetPlace {
  const SheetPlace(this.x, this.y, this.turns);

  final double x;
  final double y;

  /// Quarter turns clockwise, 0 to 3.
  final int turns;
}

final class OverlayPuzzleState {
  const OverlayPuzzleState(this.config, this.places);

  final OverlayConfig config;
  final Map<String, SheetPlace> places;

  OverlaySheet _sheet(String id) => config.sheets.firstWhere((s) => s.id == id);

  SheetPlace place(String id) => places[id]!;

  /// Whether sheet [id] lies exactly where it belongs, the right way up.
  bool isPlaced(String id) {
    final s = _sheet(id);
    final p = places[id]!;
    return p.turns == 0 && p.x == s.rect.x && p.y == s.rect.y;
  }

  bool get isSolved => config.sheets.every((s) => isPlaced(s.id));

  OverlayPuzzleState _with(String id, SheetPlace place) =>
      OverlayPuzzleState(config, {...places, id: place});

  /// Sheet [id] dragged by ([dx], [dy]), normalized. A sheet in place stays
  /// put: it has settled.
  OverlayPuzzleState move(String id, double dx, double dy) {
    if (isPlaced(id)) return this;
    final p = places[id]!;
    final s = _sheet(id);
    // Keep at least a strip of the sheet on the board.
    final x = (p.x + dx).clamp(-s.rect.width * 0.7, 1 - s.rect.width * 0.3);
    final y = (p.y + dy).clamp(-s.rect.height * 0.7, 1 - s.rect.height * 0.3);
    return _with(id, SheetPlace(x, y, p.turns));
  }

  /// Sheet [id] turned a quarter clockwise, unless it has settled.
  OverlayPuzzleState turn(String id) {
    if (isPlaced(id)) return this;
    final p = places[id]!;
    return _with(id, SheetPlace(p.x, p.y, (p.turns + 1) % 4));
  }

  /// Sheet [id] let go: it settles into its place when close enough and the
  /// right way up.
  OverlayPuzzleState drop(String id) {
    final s = _sheet(id);
    final p = places[id]!;
    if (p.turns != 0) return this;
    final distance = math.sqrt(
      math.pow(p.x - s.rect.x, 2) + math.pow(p.y - s.rect.y, 2),
    );
    if (distance > config.snap) return this;
    return _with(id, SheetPlace(s.rect.x, s.rect.y, 0));
  }
}
