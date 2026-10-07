import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:stillroom/engine/engine.dart';
import 'package:stillroom/features/game/flame/creatures.dart';

void main() {
  const area = Rect.fromLTWH(100, 100, 400, 300);

  void run(Creature c, double seconds) {
    for (var t = 0.0; t < seconds; t += 1 / 60) {
      c.update(1 / 60);
    }
  }

  test('every kind can be created, animated, and drawn', () {
    for (final kind in CreatureKind.values) {
      final creature = Creature.create(kind, area, math.Random(1), (_) {});
      run(creature, 20);
      final recorder = PictureRecorder();
      creature.render(Canvas(recorder));
      recorder.endRecording().dispose();
    }
  });

  test('a startled fulmar flies off and comes back', () {
    final sounds = <String>[];
    final fulmar = Creature.create(
      CreatureKind.fulmar,
      area,
      math.Random(1),
      sounds.add,
    );
    final seat = Offset(area.center.dx, area.bottom);
    expect(fulmar.near(seat), isTrue);
    fulmar.startle();
    expect(sounds, ['wings_flutter']);
    run(fulmar, 3);
    expect(fulmar.near(seat), isFalse, reason: 'gone');
    run(fulmar, 12);
    expect(fulmar.near(seat), isTrue, reason: 'back on its ledge');
  });

  test('geckos chirp now and then', () {
    final sounds = <String>[];
    final gecko = Creature.create(
      CreatureKind.gecko,
      area,
      math.Random(2),
      sounds.add,
    );
    run(gecko, 90);
    expect(sounds, contains('gecko_call'));
  });

  test('an eagle circles within its area and cries now and then', () {
    final sounds = <String>[];
    final eagle = Creature.create(
      CreatureKind.eagle,
      area,
      math.Random(3),
      sounds.add,
    );
    expect(eagle.near(area.center), isFalse, reason: 'too high to startle');
    run(eagle, 90);
    expect(sounds, contains('eagle_cry'));
  });

  test('a startled heron lifts off slowly and wades back', () {
    final sounds = <String>[];
    final heron = Creature.create(
      CreatureKind.heron,
      area,
      math.Random(4),
      sounds.add,
    );
    final body = Offset(area.center.dx, area.bottom - 60);
    expect(heron.near(body), isTrue);
    heron.startle();
    expect(sounds, ['wings_flutter']);
    run(heron, 4);
    expect(heron.near(body), isFalse, reason: 'gone');
    run(heron, 15);
    expect(heron.near(body), isTrue, reason: 'back in the shallows');
  });

  test('a startled seal slips off its floe and hauls out again', () {
    final sounds = <String>[];
    final seal = Creature.create(
      CreatureKind.seal,
      area,
      math.Random(5),
      sounds.add,
    );
    final floe = Offset(area.center.dx, area.bottom - 20);
    expect(seal.near(floe), isTrue);
    seal.startle();
    expect(sounds, ['splash']);
    run(seal, 3);
    expect(seal.near(floe), isFalse, reason: 'in the water');
    run(seal, 13);
    expect(seal.near(floe), isTrue, reason: 'back on the ice');
  });

  test('swifts wheel inside their area and scatter when tapped', () {
    final sounds = <String>[];
    final swifts = Creature.create(
      CreatureKind.swifts,
      area,
      math.Random(6),
      sounds.add,
    );
    run(swifts, 3);
    swifts.startle();
    expect(sounds, ['wings_flutter']);
    swifts.startle();
    expect(sounds, hasLength(1), reason: 'already scattered');
    run(swifts, 6);
    swifts.startle();
    expect(sounds, hasLength(2), reason: 'wheeling again');
  });
}
