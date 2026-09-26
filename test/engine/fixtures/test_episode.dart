import 'dart:convert';

import 'package:stillroom/engine/engine.dart';

/// Minimal puzzle type for engine tests; real v1 types arrive in M4.
final class TestCodeConfig implements PuzzleConfig {
  const TestCodeConfig(this.solution);

  final List<String> solution;

  @override
  Iterable<ContentRef> get references => const [];
}

final class TestCodePuzzleType implements PuzzleType {
  @override
  String get id => 'testCode';

  @override
  PuzzleConfig parseConfig(JsonReader config) {
    config.allowOnly({'solution'});
    return TestCodeConfig(config.strings('solution'));
  }
}

ContentRegistries testRegistries() =>
    ContentRegistries.withBuiltIns()
      ..puzzleTypes.register(TestCodePuzzleType());

/// Round-trips through JSON text so types match what the asset loader sees.
JsonReader doc(String source, Map<String, Object?> json) =>
    JsonReader.root(jsonDecode(jsonEncode(json)), source: source);

Map<String, Object?> gameJson() => {
  'startScene': 'room_north',
  'flags': {
    'drawer_open': false,
    'music_box_wound': false,
    'saw_clock': false,
    'clock_turns': 0,
  },
  'logicalResolution': [1920, 1080],
};

Map<String, Object?> itemsJson() => {
  'items': <Object?>[
    for (final id in ['small_key', 'lens', 'frame', 'magnifier', 'box', 'note'])
      {
        'id': id,
        'nameKey': 'item.$id.name',
        'descKey': 'item.$id.desc',
        'icon': 'images/items/$id.png',
      },
  ],
  'combinations': <Object?>[
    {'a': 'lens', 'b': 'frame', 'result': 'magnifier'},
  ],
};

Map<String, Object?> roomNorthJson() => {
  'id': 'room_north',
  'background': 'images/scenes/room_north.png',
  'exits': [
    {'direction': 'right', 'to': 'desk'},
    {
      'id': 'door',
      'to': 'desk',
      'rect': [0.8, 0.2, 0.1, 0.6],
      'when': [
        {'flag': 'music_box_wound', 'equals': true},
      ],
    },
  ],
  'hotspots': [
    {
      'id': 'clock',
      'rect': [0.1, 0.1, 0.2, 0.2],
      'onTap': [
        {'type': 'setFlag', 'flag': 'saw_clock', 'value': true},
        {'type': 'showText', 'key': 'room.clock.look'},
      ],
    },
    {
      'id': 'lens',
      'rect': [0.5, 0.5, 0.1, 0.1],
      'when': [
        {'everHadItem': 'lens', 'equals': false},
      ],
      'onTap': [
        {'type': 'pickItem', 'item': 'lens'},
      ],
    },
    {
      'id': 'frame',
      'rect': [0.52, 0.52, 0.04, 0.04],
      'when': [
        {'everHadItem': 'frame', 'equals': false},
      ],
      'onTap': [
        {'type': 'pickItem', 'item': 'frame'},
      ],
    },
  ],
};

Map<String, Object?> deskJson() => {
  'id': 'desk',
  'background': 'images/scenes/desk.png',
  'exits': [
    {'direction': 'back', 'to': 'room_north'},
  ],
  'hotspots': [
    {
      'id': 'drawer_locked',
      'rect': [0.42, 0.61, 0.18, 0.12],
      'when': [
        {'flag': 'drawer_open', 'equals': false},
      ],
      'onTap': [
        {'type': 'openPuzzle', 'puzzle': 'drawer_lock'},
      ],
    },
    {
      'id': 'small_key',
      'rect': [0.47, 0.64, 0.05, 0.04],
      'when': [
        {'flag': 'drawer_open', 'equals': true},
        {'everHadItem': 'small_key', 'equals': false},
      ],
      'onTap': [
        {'type': 'pickItem', 'item': 'small_key'},
      ],
    },
    {
      'id': 'music_box',
      'rect': [0.12, 0.40, 0.14, 0.18],
      'onTap': [
        {'type': 'showText', 'key': 'desk.music_box.look'},
      ],
      'onUseItem': [
        {
          'item': 'small_key',
          'actions': [
            {'type': 'removeItem', 'item': 'small_key'},
            {'type': 'setFlag', 'flag': 'music_box_wound', 'value': true},
            {'type': 'playSound', 'sound': 'music_box'},
            {'type': 'shake'},
          ],
        },
      ],
    },
    {
      'id': 'exit_door',
      'rect': [0.9, 0.0, 0.1, 1.0],
      'when': [
        {'flag': 'music_box_wound', 'equals': true},
      ],
      'onTap': [
        {'type': 'endEpisode'},
      ],
    },
  ],
  'layers': [
    {
      'id': 'drawer_open_sprite',
      'image': 'images/objects/drawer_open.png',
      'rect': [0.40, 0.58, 0.22, 0.18],
      'when': [
        {'flag': 'drawer_open', 'equals': true},
      ],
    },
  ],
};

Map<String, Object?> drawerLockJson() => {
  'id': 'drawer_lock',
  'type': 'testCode',
  'config': {
    'solution': ['3', '1', '4', '1'],
  },
  'onSolved': [
    {'type': 'setFlag', 'flag': 'drawer_open', 'value': true},
    {'type': 'goToScene', 'scene': 'desk'},
  ],
  'hints': [
    {'key': 'hint.drawer_lock.1'},
    {
      'key': 'hint.drawer_lock.2',
      'when': [
        {'flag': 'saw_clock', 'equals': true},
      ],
    },
    {'key': 'hint.drawer_lock.3'},
  ],
};

EpisodeContent buildTestEpisode({
  Map<String, Object?>? game,
  Map<String, Object?>? items,
  List<Map<String, Object?>>? scenes,
  List<Map<String, Object?>>? puzzles,
}) {
  final sceneDocs = scenes ?? [roomNorthJson(), deskJson()];
  final puzzleDocs = puzzles ?? [drawerLockJson()];
  return EpisodeContent.parse(
    id: 'test_room',
    game: doc('game.json', game ?? gameJson()),
    items: doc('items.json', items ?? itemsJson()),
    scenes: [for (final (i, s) in sceneDocs.indexed) doc('scenes/$i.json', s)],
    puzzles: [
      for (final (i, p) in puzzleDocs.indexed) doc('puzzles/$i.json', p),
    ],
    registries: testRegistries(),
  );
}
