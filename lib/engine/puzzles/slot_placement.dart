import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
import '../state/game_state.dart';
import 'puzzle_type.dart';

/// `slotPlacement`: put pieces into the right slots. Pieces start in a tray
/// (or in `initial` slots); a piece with `item` is only available while the
/// player holds that inventory item.
///
/// ```json
/// "config": {
///   "pieces": [
///     { "id": "sun", "image": "images/..." },
///     { "id": "gem", "item": "gem" }
///   ],
///   "slots": [
///     { "id": "top", "rect": [0.4, 0.1, 0.2, 0.2] }
///   ],
///   "solution": { "top": "sun" },
///   "initial": { }
/// }
/// ```
/// Slot rects are normalized to the puzzle board; a slot's optional
/// `labelKey` is shown under it. `solution` must place
/// every piece it names in a distinct slot; slots it leaves out may stay
/// empty. Consuming the items is up to `onSolved` (e.g. `removeItem`).
final class SlotPlacementType implements PuzzleType {
  const SlotPlacementType();

  static const typeId = 'slotPlacement';

  @override
  String get id => typeId;

  @override
  SlotPlacementConfig parseConfig(JsonReader json) {
    json.allowOnly({'pieces', 'slots', 'solution', 'initial'});
    final pieces = [
      for (final p in json.objects('pieces')) PlacementPiece._fromJson(p),
    ];
    final slots = [
      for (final s in json.objects('slots')) PlacementSlot._fromJson(s),
    ];
    final pieceIds = _unique(json, 'pieces', pieces.map((p) => p.id));
    final slotIds = _unique(json, 'slots', slots.map((s) => s.id));

    Map<String, String> assignment(String key, {required bool optional}) {
      if (optional && !json.has(key)) return const {};
      final map = json.object(key);
      final used = <String>{};
      return {
        for (final slot in map.json.keys)
          slot: () {
            if (!slotIds.contains(slot)) map.fail('unknown slot "$slot"', slot);
            final piece = map.string(slot);
            if (!pieceIds.contains(piece)) {
              map.fail('unknown piece "$piece"', slot);
            }
            if (!used.add(piece)) map.fail('piece "$piece" used twice', slot);
            return piece;
          }(),
      };
    }

    final solution = assignment('solution', optional: false);
    if (solution.isEmpty) json.fail('must not be empty', 'solution');
    return SlotPlacementConfig(
      pieces: pieces,
      slots: slots,
      solution: solution,
      initial: assignment('initial', optional: true),
    );
  }

  static Set<String> _unique(
    JsonReader json,
    String key,
    Iterable<String> ids,
  ) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) json.fail('duplicate id "$id"', key);
    }
    return seen;
  }
}

final class PlacementPiece {
  const PlacementPiece({required this.id, this.image, this.item});

  factory PlacementPiece._fromJson(JsonReader json) {
    json.allowOnly({'id', 'image', 'item'});
    return PlacementPiece(
      id: json.string('id'),
      image: json.optionalString('image'),
      item: json.optionalString('item'),
    );
  }

  final String id;
  final String? image;

  /// Inventory item that must be held for this piece to be available.
  final String? item;
}

final class PlacementSlot {
  const PlacementSlot({required this.id, required this.rect, this.labelKey});

  factory PlacementSlot._fromJson(JsonReader json) {
    json.allowOnly({'id', 'rect', 'labelKey'});
    return PlacementSlot(
      id: json.string('id'),
      rect: NormalizedRect.fromJson(json, 'rect'),
      labelKey: json.optionalString('labelKey'),
    );
  }

  final String id;
  final NormalizedRect rect;
  final String? labelKey;
}

final class SlotPlacementConfig implements PuzzleConfig {
  SlotPlacementConfig({
    required List<PlacementPiece> pieces,
    required List<PlacementSlot> slots,
    required Map<String, String> solution,
    required Map<String, String> initial,
  }) : pieces = List.unmodifiable(pieces),
       slots = List.unmodifiable(slots),
       solution = Map.unmodifiable(solution),
       initial = Map.unmodifiable(initial);

  final List<PlacementPiece> pieces;
  final List<PlacementSlot> slots;

  /// Slot id → piece id.
  final Map<String, String> solution;
  final Map<String, String> initial;

  PlacementPiece piece(String id) => pieces.firstWhere((p) => p.id == id);

  /// Pieces the player can use with the current inventory.
  Set<String> availablePieces(GameState game) => {
    for (final p in pieces)
      if (p.item == null || game.hasItem(p.item!)) p.id,
  };

  SlotPlacementState start(GameState game) {
    final available = availablePieces(game);
    return SlotPlacementState(this, available, {
      for (final MapEntry(key: slot, value: piece) in initial.entries)
        if (available.contains(piece)) slot: piece,
    });
  }

  @override
  Iterable<ContentRef> get references => [
    for (final p in pieces) ...[
      if (p.image case final image?) ContentRef.image(image),
      if (p.item case final item?) ContentRef.item(item),
    ],
    for (final s in slots)
      if (s.labelKey case final key?) ContentRef.text(key),
  ];
}

final class SlotPlacementState {
  SlotPlacementState(
    this.config,
    Set<String> available,
    Map<String, String> placed, {
    this.selected,
  }) : available = Set.unmodifiable(available),
       placed = Map.unmodifiable(placed);

  final SlotPlacementConfig config;

  /// Pieces usable in this attempt.
  final Set<String> available;

  /// Slot id → piece id currently in it.
  final Map<String, String> placed;

  /// Piece the player picked up, from the tray or a slot.
  final String? selected;

  /// Available pieces not in any slot, in config order.
  List<String> get tray => [
    for (final p in config.pieces)
      if (available.contains(p.id) && !placed.containsValue(p.id)) p.id,
  ];

  /// Picks up [pieceId] (from the tray), or puts it down if already held.
  SlotPlacementState selectPiece(String pieceId) {
    if (!available.contains(pieceId)) return this;
    return _copy(selected: selected == pieceId ? null : pieceId);
  }

  /// Tapping a slot places the selected piece there. An occupant swaps into
  /// the selected piece's old slot, or returns to the tray. With nothing
  /// selected, tapping an occupied slot picks its piece up.
  SlotPlacementState tapSlot(String slotId) {
    final occupant = placed[slotId];
    final moving = selected;
    if (moving == null) {
      return occupant == null ? this : _copy(selected: occupant);
    }
    if (moving == occupant) return _copy(selected: null);
    final from = _slotOf(moving);
    final next = {...placed}..removeWhere((_, p) => p == moving);
    next[slotId] = moving;
    if (occupant != null && from != null) next[from] = occupant;
    return SlotPlacementState(config, available, next);
  }

  /// Sends the piece in [slotId] back to the tray.
  SlotPlacementState clearSlot(String slotId) {
    if (!placed.containsKey(slotId)) return this;
    return SlotPlacementState(config, available, {...placed}..remove(slotId));
  }

  bool get isSolved {
    for (final MapEntry(key: slot, value: piece) in config.solution.entries) {
      if (placed[slot] != piece) return false;
    }
    return true;
  }

  String? _slotOf(String pieceId) {
    for (final MapEntry(key: slot, value: piece) in placed.entries) {
      if (piece == pieceId) return slot;
    }
    return null;
  }

  SlotPlacementState _copy({required String? selected}) =>
      SlotPlacementState(config, available, placed, selected: selected);
}
