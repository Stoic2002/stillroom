import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Every character of every language's text (UI strings and content) must be
/// in the bundled fonts, so nothing falls back to a system font or renders
/// as a blank box. The theme chains all fonts for every language
/// (`AppTheme.fallbackFor`), but Japanese text must be covered by the
/// Japanese font, Chinese text by the Chinese one and Korean text by the
/// Korean one, since Han characters and punctuation are drawn differently
/// in each. Language names (`language*` keys, shown
/// in their own script everywhere) only need some bundled font.
void main() {
  final latin = _codePoints('assets/fonts/IMFeENrm28P.ttf');
  final cyrillic = _codePoints('assets/fonts/OldStandard-Regular.ttf');
  final japanese = _codePoints('assets/fonts/NotoSerifJP-Regular-subset.ttf');
  final chinese = _codePoints('assets/fonts/NotoSerifSC-Regular-subset.ttf');
  final korean = _codePoints('assets/fonts/NotoSerifKR-Regular-subset.ttf');

  final all = [latin, cyrillic, japanese, chinese, korean];
  final strictFor = <String, List<Set<int>>>{
    'en': all,
    'id': all,
    'es': all,
    'ru': all,
    'ja': [latin, cyrillic, japanese],
    'zh': [latin, cyrillic, chinese],
    'ko': [latin, cyrillic, korean],
  };

  for (final MapEntry(key: language, value: fonts) in strictFor.entries) {
    test('$language text is covered by its fonts', () {
      final ui = _entries('lib/l10n/app_$language.arb');
      final checks = [
        for (final (key, text) in [
          ...ui,
          ..._entries('assets/content/strings/$language.json'),
        ])
          (text, key.startsWith('language') ? all : fonts),
      ];
      final missing = <String>{};
      for (final (text, allowed) in checks) {
        for (final rune in text.runes) {
          if (rune < 0x20) continue;
          if (!allowed.any((font) => font.contains(rune))) {
            missing.add(String.fromCharCode(rune));
          }
        }
      }
      expect(
        missing,
        isEmpty,
        reason:
            'add these to tool/fonts/subset_cjk_fonts.py (EXTRA) and rerun it',
      );
    });
  }
}

List<(String, String)> _entries(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@') && value is String) (key, value),
  ];
}

/// Code points in a TrueType font's `cmap` (formats 4 and 12).
Set<int> _codePoints(String path) {
  final data = ByteData.sublistView(File(path).readAsBytesSync());
  final tables = data.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < tables; i++) {
    final record = 12 + 16 * i;
    final tag = String.fromCharCodes([
      for (var j = 0; j < 4; j++) data.getUint8(record + j),
    ]);
    if (tag == 'cmap') cmap = data.getUint32(record + 8);
  }
  final points = <int>{};
  final subtables = data.getUint16(cmap + 2);
  for (var i = 0; i < subtables; i++) {
    final start = cmap + data.getUint32(cmap + 4 + 8 * i + 4);
    switch (data.getUint16(start)) {
      case 4:
        final segments = data.getUint16(start + 6) ~/ 2;
        final ends = start + 14;
        final starts = ends + segments * 2 + 2;
        for (var s = 0; s < segments; s++) {
          final end = data.getUint16(ends + s * 2);
          final first = data.getUint16(starts + s * 2);
          if (first == 0xFFFF) continue;
          for (var c = first; c <= end; c++) {
            points.add(c);
          }
        }
      case 12:
        final groups = data.getUint32(start + 12);
        for (var g = 0; g < groups; g++) {
          final group = start + 16 + g * 12;
          for (
            var c = data.getUint32(group);
            c <= data.getUint32(group + 4);
            c++
          ) {
            points.add(c);
          }
        }
    }
  }
  return points;
}
