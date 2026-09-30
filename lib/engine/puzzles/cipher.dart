import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `cipher`: a letter written in groups of numbers, and a worksheet that
/// gives the syllables for most of them, like Louis XIV's Great Cipher.
/// Tap a number in the letter, then its entry on the worksheet.
///
/// ```json
/// "config": {
///   "groups": ["124", "22", "125", "46", "345", "330", "309"],
///   "lines": [5],
///   "key": [
///     { "code": "124", "text": "les" },
///     { "code": "22", "text": "en" }
///   ]
/// }
/// ```
/// `groups` is the letter, in order; `lines` (optional) are the group
/// indices where a new line starts. `key` is the worksheet: each `code`
/// once, `text` shown as written (the cipher's own language, not
/// translated). A number is read when its entry is tapped while it is
/// selected; every group with the same number is read with it. A wrong
/// entry is a slip. Groups whose number is not on the worksheet stay
/// unread: that gap is the point. Solved when every group that can be
/// read has been.
final class CipherType implements PuzzleType {
  const CipherType();

  static const typeId = 'cipher';

  @override
  String get id => typeId;

  @override
  CipherConfig parseConfig(JsonReader json) {
    json.allowOnly({'groups', 'lines', 'key'});
    final groups = json.strings('groups');
    if (groups.length < 2) json.fail('need at least two groups', 'groups');
    final lines = [
      for (final v in json.has('lines') ? json.numbers('lines') : <double>[])
        v.toInt(),
    ];
    for (final (i, at) in lines.indexed) {
      if (at <= 0 || at >= groups.length || (i > 0 && at <= lines[i - 1])) {
        json.fail('line starts must rise within the letter', 'lines[$i]');
      }
    }
    final key = <String, String>{};
    for (final (i, entry) in json.objects('key').indexed) {
      entry.allowOnly({'code', 'text'});
      final code = entry.string('code');
      if (key.containsKey(code)) json.fail('"$code" twice', 'key[$i].code');
      key[code] = entry.string('text');
    }
    if (!groups.any(key.containsKey)) {
      json.fail('the worksheet reads nothing in the letter', 'key');
    }
    return CipherConfig(groups: groups, lines: lines, key: key);
  }
}

final class CipherConfig implements PuzzleConfig {
  CipherConfig({
    required List<String> groups,
    required List<int> lines,
    required Map<String, String> key,
  }) : groups = List.unmodifiable(groups),
       lines = List.unmodifiable(lines),
       key = Map.unmodifiable(key);

  final List<String> groups;
  final List<int> lines;

  /// Worksheet: number → syllable.
  final Map<String, String> key;

  /// Numbers in the letter that the worksheet can read.
  Set<String> get readable => {
    for (final g in groups)
      if (key.containsKey(g)) g,
  };

  /// Numbers in the letter that no worksheet has.
  Set<String> get unknown => {
    for (final g in groups)
      if (!key.containsKey(g)) g,
  };

  CipherState start() => CipherState(this, const {}, 0);

  @override
  Iterable<ContentRef> get references => const [];
}

final class CipherState {
  CipherState(this.config, Set<String> read, this.slips)
    : read = Set.unmodifiable(read);

  final CipherConfig config;

  /// Numbers read so far.
  final Set<String> read;

  /// Wrong entries tapped.
  final int slips;

  bool get isSolved => read.length == config.readable.length;

  /// The text shown for group [index]: its syllable once read, else null.
  String? textAt(int index) {
    final code = config.groups[index];
    return read.contains(code) ? config.key[code] : null;
  }

  /// With the group at [index] selected, the player taps the worksheet
  /// entry for [code]: the right one reads every group with that number.
  CipherState match(int index, String code) {
    if (isSolved) return this;
    final group = config.groups[index];
    if (read.contains(group)) return this;
    if (group == code && config.key.containsKey(code)) {
      return CipherState(config, {...read, code}, slips);
    }
    return CipherState(config, read, slips + 1);
  }
}
