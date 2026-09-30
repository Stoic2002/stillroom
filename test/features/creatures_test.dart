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
}
