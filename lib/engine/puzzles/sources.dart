import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `sources`: a file of papers about one person or event, to be sorted into
/// trays, such as what was seen at the time and what was told afterwards.
///
/// ```json
/// "config": {
///   "trays": [
///     { "id": "time", "labelKey": "…" },
///     { "id": "after", "labelKey": "…" }
///   ],
///   "cards": [
///     { "id": "louvois_1669", "titleKey": "…", "textKey": "…", "tray": "time" }
///   ]
/// }
/// ```
/// Each card has a title (who wrote it, and when if it says) and a short
/// text, and belongs in one `tray`. The player drags or taps a card into a
/// tray, and can move it again. Once every card is in a tray, the file says
/// how many are in the wrong one; solved when none are.
final class SourcesType implements PuzzleType {
  const SourcesType();

  static const typeId = 'sources';

  @override
  String get id => typeId;

  @override
  SourcesConfig parseConfig(JsonReader json) {
    json.allowOnly({'trays', 'cards'});
    final trays = [
      for (final t in json.objects('trays'))
        () {
          t.allowOnly({'id', 'labelKey'});
          return SourcesTray(
            id: t.string('id'),
            labelKey: t.string('labelKey'),
          );
        }(),
    ];
    if (trays.length < 2) json.fail('need at least two trays', 'trays');
    final trayIds = {for (final t in trays) t.id};
    if (trayIds.length != trays.length) {
      json.fail('tray ids must be unique', 'trays');
    }
    final cards = [
      for (final c in json.objects('cards'))
        () {
          c.allowOnly({'id', 'titleKey', 'textKey', 'tray'});
          final tray = c.string('tray');
          if (!trayIds.contains(tray)) c.fail('unknown tray "$tray"', 'tray');
          return SourcesCard(
            id: c.string('id'),
            titleKey: c.string('titleKey'),
            textKey: c.string('textKey'),
            tray: tray,
          );
        }(),
    ];
    if (cards.length < 3) json.fail('need at least three cards', 'cards');
    if ({for (final c in cards) c.id}.length != cards.length) {
      json.fail('card ids must be unique', 'cards');
    }
    for (final t in trays) {
      if (!cards.any((c) => c.tray == t.id)) {
        json.fail('no card belongs in tray "${t.id}"', 'trays');
      }
    }
    return SourcesConfig(trays: trays, cards: cards);
  }
}

final class SourcesTray {
  const SourcesTray({required this.id, required this.labelKey});

  final String id;
  final String labelKey;
}

final class SourcesCard {
  const SourcesCard({
    required this.id,
    required this.titleKey,
    required this.textKey,
    required this.tray,
  });

  final String id;
  final String titleKey;
  final String textKey;

  /// The tray it belongs in.
  final String tray;
}

final class SourcesConfig implements PuzzleConfig {
  SourcesConfig({
    required List<SourcesTray> trays,
    required List<SourcesCard> cards,
  }) : trays = List.unmodifiable(trays),
       cards = List.unmodifiable(cards);

  final List<SourcesTray> trays;
  final List<SourcesCard> cards;

  SourcesCard card(String id) => cards.firstWhere((c) => c.id == id);

  SourcesState start() => SourcesState(this, const {});

  @override
  Iterable<ContentRef> get references => [
    for (final t in trays) ContentRef.text(t.labelKey),
    for (final c in cards) ...[
      ContentRef.text(c.titleKey),
      ContentRef.text(c.textKey),
    ],
  ];
}

final class SourcesState {
  SourcesState(this.config, Map<String, String> placed)
    : placed = Map.unmodifiable(placed);

  final SourcesConfig config;

  /// Card id → the tray it has been put in.
  final Map<String, String> placed;

  bool get isComplete => placed.length == config.cards.length;

  /// Cards in the wrong tray (counted once every card is placed).
  int get wrong => [
    for (final c in config.cards)
      if (placed[c.id] != null && placed[c.id] != c.tray) c,
  ].length;

  bool get isSolved => isComplete && wrong == 0;

  /// Puts [cardId] in [trayId], or moves it there.
  SourcesState place(String cardId, String trayId) {
    if (isSolved) return this;
    return SourcesState(config, {...placed, cardId: trayId});
  }

  /// Takes [cardId] back out of its tray.
  SourcesState lift(String cardId) {
    if (isSolved || !placed.containsKey(cardId)) return this;
    return SourcesState(config, {...placed}..remove(cardId));
  }
}
