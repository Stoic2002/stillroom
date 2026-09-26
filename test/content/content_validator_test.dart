import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/content/content_validator.dart';
import 'package:stillroom/engine/engine.dart';

import '../engine/fixtures/test_episode.dart';

/// Every text key the fixture episode uses.
final _fixtureKeys = [
  'room.clock.look',
  'desk.music_box.look',
  'hint.drawer_lock.1',
  'hint.drawer_lock.2',
  'hint.drawer_lock.3',
  for (final id in [
    'small_key',
    'lens',
    'frame',
    'magnifier',
    'box',
    'note',
  ]) ...['item.$id.name', 'item.$id.desc'],
];

Map<String, Map<String, String>> _strings() => {
  for (final locale in ['en', 'id'])
    locale: {for (final k in _fixtureKeys) k: 'TODO_TEXT'},
};

List<ContentIssue> _validate(
  EpisodeContent content, {
  Set<String> assets = const {},
  Map<String, Map<String, String>>? strings,
}) => validateEpisode(content, assets: assets, strings: strings ?? _strings());

List<String> _errors(List<ContentIssue> issues) => [
  for (final i in issues)
    if (i.isError) '${i.location}: ${i.message}',
];

void main() {
  test('the fixture episode has no errors', () {
    expect(_errors(_validate(buildTestEpisode())), isEmpty);
  });

  test('missing images and sounds are warnings, not errors', () {
    final issues = _validate(buildTestEpisode());
    final warnings = issues.where((i) => !i.isError).map((i) => i.message);
    expect(warnings, contains(contains('images/scenes/desk.png')));
    expect(warnings, contains(contains('sound "music_box"')));

    final withArt = _validate(
      buildTestEpisode(),
      assets: {
        'assets/images/scenes/desk.png',
        'assets/audio/sfx/music_box.ogg',
      },
    );
    final remaining = withArt.map((i) => i.message).join('\n');
    expect(remaining, isNot(contains('images/scenes/desk.png')));
    expect(remaining, isNot(contains('music_box')));
  });

  test('broken references are errors with a readable location', () {
    final desk = deskJson();
    final hotspots = desk['hotspots']! as List<Object?>;
    (hotspots[0]! as Map<String, Object?>)['onTap'] = [
      {'type': 'goToScene', 'scene': 'attic'},
      {'type': 'pickItem', 'item': 'crown'},
      {'type': 'openPuzzle', 'puzzle': 'riddle'},
      {'type': 'setFlag', 'flag': 'ghost', 'value': true},
      {'type': 'setFlag', 'flag': 'clock_turns', 'value': true},
    ];
    (hotspots[1]! as Map<String, Object?>)['when'] = [
      {'flag': 'drawer_open', 'equals': 2},
    ];
    final errors = _errors(
      _validate(buildTestEpisode(scenes: [roomNorthJson(), desk])),
    );
    expect(errors, [
      'scene desk › hotspot drawer_locked › onTap[0] goToScene: unknown scene "attic"',
      'scene desk › hotspot drawer_locked › onTap[1] pickItem: unknown item "crown"',
      'scene desk › hotspot drawer_locked › onTap[2] openPuzzle: unknown puzzle "riddle"',
      'scene desk › hotspot drawer_locked › onTap[3] setFlag: flag "ghost" is not declared in game.json',
      'scene desk › hotspot drawer_locked › onTap[4] setFlag: flag "clock_turns" is int but is used with true',
      'scene desk › hotspot small_key › when[0]: flag "drawer_open" is bool but is used with 2',
    ]);
  });

  test('exit targets, use-item ids, and combinations are checked', () {
    final room = roomNorthJson();
    ((room['exits']! as List<Object?>)[0]! as Map<String, Object?>)['to'] =
        'attic';
    final desk = deskJson();
    final musicBox =
        (desk['hotspots']! as List<Object?>)[2]! as Map<String, Object?>;
    ((musicBox['onUseItem']! as List<Object?>)[0]!
            as Map<String, Object?>)['item'] =
        'crown';
    final items = itemsJson();
    (items['combinations']! as List<Object?>).add({
      'a': 'lens',
      'b': 'box',
      'result': 'orb',
    });

    final errors = _errors(
      _validate(buildTestEpisode(scenes: [room, desk], items: items)),
    );
    expect(errors, [
      'scene room_north › exit right: unknown scene "attic"',
      'scene desk › hotspot music_box › onUseItem crown: unknown item "crown"',
      'items.json › combinations[1]: unknown item "orb"',
    ]);
  });

  test('rects outside 0–1 are errors', () {
    final desk = deskJson();
    ((desk['hotspots']! as List<Object?>)[0]! as Map<String, Object?>)['rect'] =
        [0.9, 0.5, 0.2, 0.1];
    expect(
      _errors(_validate(buildTestEpisode(scenes: [roomNorthJson(), desk]))),
      [contains('scene desk › hotspot drawer_locked: rect')],
    );
  });

  test('invalid startScene is an error', () {
    final content = buildTestEpisode(
      game: {...gameJson(), 'startScene': 'attic'},
    );
    expect(_errors(_validate(content)), [
      'episode test_room › game.json: startScene "attic" does not exist',
    ]);
  });

  test('text keys must exist in every language', () {
    final strings = _strings();
    strings['id']!.remove('room.clock.look');
    expect(_errors(_validate(buildTestEpisode(), strings: strings)), [
      'strings/id.json: missing keys present in other languages: room.clock.look',
      'scene room_north › hotspot clock › onTap[1] showText: text key "room.clock.look" missing in id',
    ]);
  });

  test('item name/desc keys and hint keys are checked', () {
    final strings = _strings();
    for (final table in strings.values) {
      table
        ..remove('item.lens.name')
        ..remove('hint.drawer_lock.2');
    }
    expect(_errors(_validate(buildTestEpisode(), strings: strings)), [
      'item lens: text key "item.lens.name" missing in en, id',
      'puzzle drawer_lock › hints[1]: text key "hint.drawer_lock.2" missing in en, id',
    ]);
  });
}
