import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `keyring`: a turnkey's ring of keys and a lock seen from the front. Each
/// key's bit has its own cuts; the keyhole shows the shape the bit must
/// match. Pick a key, turn it the right way up, and try it.
///
/// ```json
/// "config": {
///   "profile": [2, 0, 3, 1],
///   "keys": [
///     { "id": "k1", "bits": [1, 3, 0, 2] },
///     { "id": "k2", "bits": [1, 3, 0, 2] }
///   ]
/// }
/// ```
/// `profile` is the keyhole's shape: how deep the bit is cut at each place
/// along it (0 to 3), from the stem to the tip. A key's `bits` are read the
/// same way when it is held the right way up; turned over, they read from
/// the tip back. Exactly one key must fit, and in only one way round.
final class KeyringType implements PuzzleType {
  const KeyringType();

  static const typeId = 'keyring';

  @override
  String get id => typeId;

  @override
  KeyringConfig parseConfig(JsonReader json) {
    json.allowOnly({'profile', 'keys'});
    final profile = _cuts(json, 'profile');
    final keys = [
      for (final k in json.objects('keys'))
        () {
          k.allowOnly({'id', 'bits'});
          final bits = _cuts(k, 'bits');
          if (bits.length != profile.length) {
            k.fail('one cut per place in the profile', 'bits');
          }
          return RingKey(id: k.string('id'), bits: bits);
        }(),
    ];
    if (keys.length < 2) json.fail('need at least two keys', 'keys');
    if ({for (final k in keys) k.id}.length != keys.length) {
      json.fail('key ids must be unique', 'keys');
    }
    final config = KeyringConfig(profile: profile, keys: keys);
    final fits = [
      for (final k in keys)
        for (final flipped in [false, true])
          if (config.fits(k.id, flipped: flipped)) (k.id, flipped),
    ];
    if (fits.length != 1) {
      json.fail(
        'exactly one key must fit, one way round (found ${fits.length})',
        'keys',
      );
    }
    return config;
  }

  static List<int> _cuts(JsonReader json, String key) {
    final values = json.numbers(key);
    if (values.length < 3 || values.length > 8) {
      json.fail('need 3 to 8 cuts', key);
    }
    return [
      for (final (i, v) in values.indexed)
        if (v == v.roundToDouble() && v >= 0 && v <= 3)
          v.toInt()
        else
          json.fail('cuts are whole numbers 0 to 3', '$key[$i]'),
    ];
  }
}

final class RingKey {
  RingKey({required this.id, required List<int> bits})
    : bits = List.unmodifiable(bits);

  final String id;

  /// Cut depths along the bit, stem to tip, held the right way up.
  final List<int> bits;

  /// The bit as the keyhole sees it, [flipped] or not.
  List<int> seen({required bool flipped}) =>
      flipped ? bits.reversed.toList() : bits;
}

final class KeyringConfig implements PuzzleConfig {
  KeyringConfig({required List<int> profile, required List<RingKey> keys})
    : profile = List.unmodifiable(profile),
      keys = List.unmodifiable(keys);

  final List<int> profile;
  final List<RingKey> keys;

  RingKey key(String id) => keys.firstWhere((k) => k.id == id);

  bool fits(String keyId, {required bool flipped}) {
    final seen = key(keyId).seen(flipped: flipped);
    for (var i = 0; i < profile.length; i++) {
      if (seen[i] != profile[i]) return false;
    }
    return true;
  }

  KeyringState start() =>
      KeyringState(this, selected: null, flipped: false, tries: 0);

  @override
  Iterable<ContentRef> get references => const [];
}

final class KeyringState {
  const KeyringState(
    this.config, {
    required this.selected,
    required this.flipped,
    required this.tries,
    this.open = false,
  });

  final KeyringConfig config;

  /// The key in hand, if any.
  final String? selected;

  /// Whether the key in hand is turned over.
  final bool flipped;

  /// Wrong tries so far.
  final int tries;
  final bool open;

  bool get isSolved => open;

  /// Takes [keyId] off the ring, the right way up.
  KeyringState select(String keyId) => open
      ? this
      : KeyringState(config, selected: keyId, flipped: false, tries: tries);

  /// Turns the key in hand over.
  KeyringState flip() => open || selected == null
      ? this
      : KeyringState(
          config,
          selected: selected,
          flipped: !flipped,
          tries: tries,
        );

  /// Tries the key in hand in the lock: it opens if it fits as held.
  KeyringState tryKey() {
    final key = selected;
    if (open || key == null) return this;
    if (config.fits(key, flipped: flipped)) {
      return KeyringState(
        config,
        selected: key,
        flipped: flipped,
        tries: tries,
        open: true,
      );
    }
    return KeyringState(
      config,
      selected: key,
      flipped: flipped,
      tries: tries + 1,
    );
  }
}
