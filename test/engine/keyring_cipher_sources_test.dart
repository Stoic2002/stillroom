import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';

import 'puzzle_types_test.dart' show parse, throwsAt;

void main() {
  group('keyring', () {
    KeyringConfig config() => parse<KeyringConfig>('keyring', {
      'profile': [2, 0, 3, 1],
      'keys': [
        {
          'id': 'wrong',
          'bits': [2, 0, 3, 2],
        },
        {
          'id': 'right',
          'bits': [1, 3, 0, 2],
        },
      ],
    });

    test('the right key opens only when turned the right way', () {
      var state = config().start().select('right').tryKey();
      expect(state.isSolved, isFalse);
      expect(state.tries, 1);
      state = state.flip().tryKey();
      expect(state.isSolved, isTrue);
    });

    test('a wrong key never opens it', () {
      var state = config().start().select('wrong');
      state = state.tryKey().flip().tryKey();
      expect(state.isSolved, isFalse);
      expect(state.tries, 2);
    });

    test('exactly one key must fit, one way round', () {
      expect(
        () => parse<KeyringConfig>('keyring', {
          'profile': [1, 2, 1],
          'keys': [
            {
              'id': 'a',
              'bits': [1, 2, 1],
            },
            {
              'id': 'b',
              'bits': [0, 0, 0],
            },
          ],
        }),
        throwsAt(r'$.config.keys'),
        reason: 'a symmetrical key fits both ways',
      );
    });
  });

  group('cipher', () {
    CipherConfig config() => parse<CipherConfig>('cipher', {
      'groups': ['124', '22', '125', '22', '330', '309'],
      'lines': [4],
      'key': [
        {'code': '124', 'text': 'les'},
        {'code': '22', 'text': 'en'},
        {'code': '125', 'text': 'ne'},
        {'code': '46', 'text': 'mis'},
      ],
    });

    test('the right entry reads every group with its number', () {
      var state = config().start();
      state = state.match(1, '22');
      expect(state.textAt(1), 'en');
      expect(state.textAt(3), 'en');
      expect(state.textAt(0), isNull);
    });

    test('a wrong entry is a slip', () {
      final state = config().start().match(0, '125');
      expect(state.slips, 1);
      expect(state.textAt(0), isNull);
    });

    test('numbers on no worksheet stay unread; the rest solves it', () {
      final c = config();
      expect(c.unknown, {'330', '309'});
      var state = c.start();
      for (final (i, code) in [(0, '124'), (1, '22'), (2, '125')]) {
        state = state.match(i, code);
      }
      expect(state.isSolved, isTrue);
      expect(state.textAt(4), isNull);
    });

    test('line starts must fall within the letter', () {
      expect(
        () => parse<CipherConfig>('cipher', {
          'groups': ['1', '2'],
          'lines': [2],
          'key': [
            {'code': '1', 'text': 'a'},
          ],
        }),
        throwsAt(r'$.config.lines[0]'),
      );
    });
  });

  group('sources', () {
    SourcesConfig config() => parse<SourcesConfig>('sources', {
      'trays': [
        {'id': 'time', 'labelKey': 'tray.time'},
        {'id': 'after', 'labelKey': 'tray.after'},
      ],
      'cards': [
        {'id': 'a', 'titleKey': 'a.t', 'textKey': 'a.x', 'tray': 'time'},
        {'id': 'b', 'titleKey': 'b.t', 'textKey': 'b.x', 'tray': 'after'},
        {'id': 'c', 'titleKey': 'c.t', 'textKey': 'c.x', 'tray': 'time'},
      ],
    });

    test('checked once every card is in a tray', () {
      var state = config().start().place('a', 'time').place('b', 'time');
      expect(state.isComplete, isFalse);
      state = state.place('c', 'time');
      expect(state.isComplete, isTrue);
      expect(state.wrong, 1);
      expect(state.isSolved, isFalse);
      state = state.place('b', 'after');
      expect(state.isSolved, isTrue);
    });

    test('a card can be taken back out', () {
      final state = config().start().place('a', 'after').lift('a');
      expect(state.placed, isEmpty);
    });

    test('every tray needs a card that belongs there', () {
      expect(
        () => parse<SourcesConfig>('sources', {
          'trays': [
            {'id': 'time', 'labelKey': 't'},
            {'id': 'after', 'labelKey': 'a'},
          ],
          'cards': [
            for (final id in ['a', 'b', 'c'])
              {'id': id, 'titleKey': 't', 'textKey': 'x', 'tray': 'time'},
          ],
        }),
        throwsAt(r'$.config.trays'),
      );
    });
  });
}
