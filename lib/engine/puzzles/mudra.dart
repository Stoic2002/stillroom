import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// The gestures of a Buddha's hands, as set by side at Borobudur.
enum Mudra {
  /// Touching the earth (bhūmisparśa): the east.
  earth,

  /// Giving (vara): the south.
  giving,

  /// Meditation (dhyāna): the west.
  meditation,

  /// No fear (abhaya): the north.
  noFear,

  /// Teaching (vitarka): the fifth balustrade.
  teaching,

  /// Turning the wheel (dharmacakra): inside the latticed stupas.
  wheel,
}

/// `mudra`: fallen Buddhas, each known only by the gesture of its hands,
/// and the places on the monument where each gesture belongs. Pick a
/// statue, then a place: the place its hands belong to takes it, while it
/// has room; any other place is a mistake.
///
/// ```json
/// "config": {
///   "statues": ["earth", "noFear", "wheel"],
///   "places": [
///     { "labelKey": "ep.mudra.east", "mudra": "earth", "slots": 1 },
///     { "labelKey": "ep.mudra.north", "mudra": "noFear", "slots": 1 },
///     { "labelKey": "ep.mudra.stupa", "mudra": "wheel", "slots": 1 }
///   ]
/// }
/// ```
/// 3 to 12 statues; 2 to 6 places, each a different gesture, with exactly
/// as many slots as there are statues with that gesture.
final class MudraType implements PuzzleType {
  const MudraType();

  static const typeId = 'mudra';

  @override
  String get id => typeId;

  @override
  MudraConfig parseConfig(JsonReader json) {
    json.allowOnly({'statues', 'places'});
    Mudra gesture(String name, String key, JsonReader at) =>
        Mudra.values.asNameMap()[name] ??
        at.fail('one of ${Mudra.values.map((m) => m.name).join(', ')}', key);
    final names = json.strings('statues');
    final statues = [
      for (var i = 0; i < names.length; i++)
        gesture(names[i], 'statues[$i]', json),
    ];
    if (statues.length < 3 || statues.length > 12) {
      json.fail('need 3 to 12 statues', 'statues');
    }
    final places = [
      for (final p in json.objects('places'))
        () {
          p.allowOnly({'labelKey', 'mudra', 'slots'});
          return MudraPlace(
            labelKey: p.string('labelKey'),
            mudra: gesture(p.string('mudra'), 'mudra', p),
            slots: p.integer('slots'),
          );
        }(),
    ];
    if (places.length < 2 || places.length > 6) {
      json.fail('need 2 to 6 places', 'places');
    }
    if (places.map((p) => p.mudra).toSet().length != places.length) {
      json.fail('each place a different gesture', 'places');
    }
    for (final (i, p) in places.indexed) {
      final count = statues.where((s) => s == p.mudra).length;
      if (p.slots != count) {
        json.fail('slots must match the $count statues with it', 'places[$i]');
      }
    }
    if (places.fold(0, (n, p) => n + p.slots) != statues.length) {
      json.fail('every statue needs a place', 'statues');
    }
    return MudraConfig(statues: statues, places: places);
  }
}

final class MudraPlace {
  const MudraPlace({
    required this.labelKey,
    required this.mudra,
    required this.slots,
  });

  final String labelKey;
  final Mudra mudra;
  final int slots;
}

/// What setting a statue in a place came to.
enum MudraSet { set, wrong, full, none }

final class MudraConfig implements PuzzleConfig {
  MudraConfig({required List<Mudra> statues, required List<MudraPlace> places})
    : statues = List.unmodifiable(statues),
      places = List.unmodifiable(places);

  final List<Mudra> statues;
  final List<MudraPlace> places;

  MudraState start() => MudraState(this, const {}, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final p in places) ContentRef.text(p.labelKey),
  ];
}

final class MudraState {
  MudraState(this.config, Map<int, int> placed, this.mistakes)
    : placed = Map.unmodifiable(placed);

  final MudraConfig config;

  /// Statues set so far, and the place each is in.
  final Map<int, int> placed;
  final int mistakes;

  bool get isSolved => placed.length == config.statues.length;

  /// How many statues place [p] holds now.
  int filled(int p) => placed.values.where((v) => v == p).length;

  MudraSet judge(int statue, int place) {
    if (placed.containsKey(statue)) return MudraSet.none;
    final p = config.places[place];
    if (p.mudra != config.statues[statue]) return MudraSet.wrong;
    if (filled(place) >= p.slots) return MudraSet.full;
    return MudraSet.set;
  }

  /// Sets [statue] in [place].
  MudraState set(int statue, int place) => switch (judge(statue, place)) {
    MudraSet.set => MudraState(config, {...placed, statue: place}, mistakes),
    MudraSet.wrong => MudraState(config, placed, mistakes + 1),
    MudraSet.full || MudraSet.none => this,
  };
}
