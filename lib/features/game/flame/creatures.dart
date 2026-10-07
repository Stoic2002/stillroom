import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../engine/engine.dart';

/// Plays an ambient sound id (content `audio/sfx/<id>`).
typedef CreatureSound = void Function(String soundId);

/// A small living thing in a scene (`creatures`). Drawn in code, cheap to
/// animate, never blocks a tap: a tap near it may only startle it.
abstract class Creature extends Component {
  Creature(this.area, this.random, this.sound) : super(priority: 450);

  /// Where it lives, in scene pixels.
  final Rect area;
  final math.Random random;
  final CreatureSound sound;

  /// Whether a tap at [p] (scene pixels) comes near enough to startle it.
  bool near(Offset p);

  void startle();

  double _t = 0;
  double get time => _t;

  @override
  void update(double dt) => _t += dt;

  static Creature create(
    CreatureKind kind,
    Rect area,
    math.Random random,
    CreatureSound sound,
  ) => switch (kind) {
    CreatureKind.gecko => _Gecko(area, random, sound),
    CreatureKind.rat => _Rat(area, random, sound),
    CreatureKind.moth => _Moth(area, random, sound),
    CreatureKind.bats => _Bats(area, random, sound),
    CreatureKind.gull => _Gull(area, random, sound),
    CreatureKind.fulmar => _Fulmar(area, random, sound),
    CreatureKind.grass => _Grass(area, random, sound),
    CreatureKind.eagle => _Eagle(area, random, sound),
    CreatureKind.raven => _Fulmar(area, random, sound, raven: true),
    CreatureKind.heron => _Heron(area, random, sound),
    CreatureKind.seal => _Seal(area, random, sound),
    CreatureKind.swifts => _Swifts(area, random, sound),
  };
}

Offset _lerp(Offset a, Offset b, double t) => a + (b - a) * t;

// ---------------------------------------------------------------------------
// Gecko (cicak): pale, clings to the wall, darts, stops, chirps.

class _Gecko extends Creature {
  _Gecko(super.area, super.random, super.sound) {
    _pos = _randomSpot();
    _heading = random.nextDouble() * math.pi * 2;
    _rest = 0.5 + random.nextDouble() * 2;
    _nextCall = 12 + random.nextDouble() * 25;
  }

  static const length = 66.0;
  static const _skin = Color(0xE6CFC3A6);
  static const _edge = Color(0x99554A38);

  late Offset _pos;
  late double _heading;
  Offset? _target;
  double _speed = 280;
  double _rest = 0;
  double _stride = 0;
  double _nextCall = 0;
  double _hidden = 0;
  double _opacity = 1;

  Offset _randomSpot() => Offset(
    area.left + random.nextDouble() * area.width,
    area.top + random.nextDouble() * area.height,
  );

  @override
  bool near(Offset p) => _hidden <= 0 && (p - _pos).distance < length * 1.3;

  @override
  void startle() {
    if (_target != null && _speed > 400) return;
    // Bolt for the nearest edge of its wall.
    final toLeft = _pos.dx - area.left < area.right - _pos.dx;
    _target = Offset(
      toLeft ? area.left - length * 2 : area.right + length * 2,
      _pos.dy,
    );
    _speed = 900;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_hidden > 0) {
      _hidden -= dt;
      if (_hidden <= 0) {
        _pos = _randomSpot();
        _opacity = 0;
      }
      return;
    }
    _opacity = math.min(1, _opacity + dt * 1.5);
    _nextCall -= dt;
    if (_nextCall <= 0) {
      _nextCall = 20 + random.nextDouble() * 30;
      sound('gecko_call');
    }
    final target = _target;
    if (target == null) {
      _rest -= dt;
      if (_rest <= 0) {
        // A short dash to a nearby spot.
        final angle = random.nextDouble() * math.pi * 2;
        final step = 60 + random.nextDouble() * 140;
        final next = _pos + Offset(math.cos(angle), math.sin(angle)) * step;
        _target = Offset(
          next.dx.clamp(area.left, area.right),
          next.dy.clamp(area.top, area.bottom),
        );
        _speed = 240 + random.nextDouble() * 120;
      }
      return;
    }
    final delta = target - _pos;
    final dist = delta.distance;
    if (dist < 2) {
      _target = null;
      _rest = 0.6 + random.nextDouble() * 2.5;
      if (!area.inflate(length).contains(_pos)) {
        _hidden = 6 + random.nextDouble() * 6;
      }
      return;
    }
    _heading = math.atan2(delta.dy, delta.dx);
    final move = math.min(dist, _speed * dt);
    _pos += delta / dist * move;
    _stride += move * 0.12;
  }

  @override
  void render(Canvas canvas) {
    if (_hidden > 0) return;
    final paint = Paint()..color = _skin.withValues(alpha: _skin.a * _opacity);
    final edge = Paint()
      ..color = _edge.withValues(alpha: _edge.a * _opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final legs = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas
      ..save()
      ..translate(_pos.dx, _pos.dy)
      ..rotate(_heading);
    const l = length;
    final moving = _target != null;
    final wiggle = moving ? math.sin(_stride) : 0.0;
    // Legs: front and back pairs, swinging while it runs.
    for (final (x, phase) in [(l * 0.18, 0.0), (-l * 0.12, math.pi)]) {
      for (final side in [-1.0, 1.0]) {
        final swing = wiggle * side * (phase == 0 ? 1 : -1) * 0.5;
        final foot = Offset(x + math.cos(swing) * l * 0.1, side * l * 0.2);
        canvas.drawLine(Offset(x, side * l * 0.05), foot, legs);
      }
    }
    // Tail, curving.
    final tail = Path()
      ..moveTo(-l * 0.25, 0)
      ..quadraticBezierTo(
        -l * 0.5,
        wiggle * l * 0.12 + l * 0.04,
        -l * 0.75,
        wiggle * l * 0.08,
      );
    canvas
      ..drawPath(
        tail,
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      )
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: l * 0.55, height: l * 0.16),
        paint,
      )
      ..drawOval(
        Rect.fromCenter(
          center: const Offset(l * 0.33, 0),
          width: l * 0.18,
          height: l * 0.13,
        ),
        paint,
      )
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: l * 0.55, height: l * 0.16),
        edge,
      )
      ..restore();
  }
}

// ---------------------------------------------------------------------------
// Rat: now and then scurries across the floor.

class _Rat extends Creature {
  _Rat(super.area, super.random, super.sound) {
    _wait = 3 + random.nextDouble() * 8;
  }

  double _wait = 0;
  double? _x;
  double _dir = 1;
  double _speed = 420;

  @override
  bool near(Offset p) {
    final x = _x;
    return x != null && (p - Offset(x, area.bottom)).distance < 80;
  }

  @override
  void startle() => _speed = 900;

  @override
  void update(double dt) {
    super.update(dt);
    final x = _x;
    if (x == null) {
      _wait -= dt;
      if (_wait <= 0) {
        _dir = random.nextBool() ? 1 : -1;
        _x = _dir > 0 ? area.left - 60 : area.right + 60;
        _speed = 380 + random.nextDouble() * 120;
      }
      return;
    }
    final next = x + _dir * _speed * dt;
    if (next < area.left - 80 || next > area.right + 80) {
      _x = null;
      _wait = 10 + random.nextDouble() * 18;
    } else {
      _x = next;
    }
  }

  @override
  void render(Canvas canvas) {
    final x = _x;
    if (x == null) return;
    final hop = math.sin(time * 30).abs() * 3;
    const body = Color(0xFF2B2522);
    canvas
      ..save()
      ..translate(x, area.bottom - 10 - hop)
      ..scale(_dir, 1)
      ..drawOval(const Rect.fromLTWH(-22, -9, 40, 18), Paint()..color = body)
      ..drawOval(const Rect.fromLTWH(12, -7, 16, 12), Paint()..color = body)
      ..drawCircle(const Offset(15, -8), 4, Paint()..color = body)
      ..drawPath(
        Path()
          ..moveTo(-20, 0)
          ..quadraticBezierTo(-40, 6 + hop, -58, -2),
        Paint()
          ..color = const Color(0xFF6A5A52)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      )
      ..restore();
  }
}

// ---------------------------------------------------------------------------
// Moth: circles a flame.

class _Moth extends Creature {
  _Moth(super.area, super.random, super.sound)
    : _phase = random.nextDouble() * 10;

  final double _phase;
  double _gone = 0;

  Offset get _pos {
    final t = time + _phase;
    return area.center +
        Offset(
          math.cos(t * 1.3) * area.width / 2 + math.sin(t * 3.1) * 8,
          math.sin(t * 2.2) * area.height / 2,
        );
  }

  @override
  bool near(Offset p) => _gone <= 0 && (p - _pos).distance < 60;

  @override
  void startle() => _gone = 5;

  @override
  void update(double dt) {
    super.update(dt);
    if (_gone > 0) _gone -= dt;
  }

  @override
  void render(Canvas canvas) {
    if (_gone > 0) return;
    final p = _pos;
    final beat = 0.3 + 0.7 * math.sin(time * 34).abs();
    final wing = Paint()..color = const Color(0xCC5C4A38);
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..scale(1, beat);
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(side * 7, 0), width: 12, height: 16),
        wing,
      );
    }
    canvas.restore();
  }
}

// ---------------------------------------------------------------------------
// Bats: hang from the vault; now and then one flies a loop.

class _Bats extends Creature {
  _Bats(super.area, super.random, super.sound) {
    for (var i = 0; i < 3; i++) {
      _roost.add(Offset(area.left + area.width * (0.2 + 0.3 * i), area.top));
      _flight.add(-1);
    }
    _wait = 3 + random.nextDouble() * 6;
  }

  final List<Offset> _roost = [];

  /// Seconds into a flight, or -1 while hanging.
  final List<double> _flight = [];
  double _wait = 0;
  static const _flightTime = 3.2;
  static const _dark = Color(0xFF15110F);

  @override
  bool near(Offset p) => area.inflate(80).contains(p);

  @override
  void startle() {
    for (var i = 0; i < _flight.length; i++) {
      if (_flight[i] < 0) _flight[i] = random.nextDouble() * 0.4;
    }
    sound('wings_flutter');
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var i = 0; i < _flight.length; i++) {
      if (_flight[i] >= 0) {
        _flight[i] += dt;
        if (_flight[i] > _flightTime) _flight[i] = -1;
      }
    }
    _wait -= dt;
    if (_wait <= 0) {
      _wait = 6 + random.nextDouble() * 9;
      final i = random.nextInt(_flight.length);
      if (_flight[i] < 0) {
        _flight[i] = 0;
        sound('wings_flutter');
      }
    }
  }

  static const _scale = 1.8;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = _dark;
    final wings = Paint()
      ..color = _dark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < _roost.length; i++) {
      final f = _flight[i];
      final Offset pos;
      if (f < 0) {
        pos = _roost[i];
      } else {
        // A loop out over the room and back to the roost.
        final t = f / _flightTime;
        final a = t * math.pi * 2;
        final loop =
            _roost[i] +
            Offset(
              math.sin(a) * area.width * 0.6,
              area.height * 1.2 - math.cos(a) * area.height * 1.1,
            );
        pos = t < 0.08 || t > 0.92
            ? _lerp(_roost[i], loop, math.min(t, 1 - t) / 0.08)
            : loop;
      }
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..scale(_scale);
      if (f < 0) {
        // Hanging, wings folded: a small dark drop with two ears.
        canvas
          ..drawOval(
            Rect.fromCenter(center: const Offset(0, 16), width: 14, height: 26),
            paint,
          )
          ..drawPath(
            Path()..addPolygon(const [
              Offset(-6, 28),
              Offset(-3, 34),
              Offset(0, 28),
            ], true),
            paint,
          )
          ..drawPath(
            Path()..addPolygon(const [
              Offset(0, 28),
              Offset(3, 34),
              Offset(6, 28),
            ], true),
            paint,
          );
      } else {
        final flap = math.sin(time * 26) * 12;
        canvas
          ..drawOval(
            Rect.fromCenter(center: Offset.zero, width: 10, height: 14),
            paint,
          )
          ..drawPath(
            Path()
              ..moveTo(0, 0)
              ..lineTo(-22, -flap)
              ..lineTo(-10, 4)
              ..moveTo(0, 0)
              ..lineTo(22, -flap)
              ..lineTo(10, 4),
            wings,
          );
      }
      canvas.restore();
    }
  }
}

// ---------------------------------------------------------------------------
// Gull: crosses the sky now and then, sometimes crying.

class _Gull extends Creature {
  _Gull(super.area, super.random, super.sound) {
    _wait = 1 + random.nextDouble() * 5;
  }

  double _wait = 0;
  double? _x;
  double _y = 0;
  double _dir = 1;
  double _speed = 220;

  @override
  bool near(Offset p) => false;

  @override
  void startle() {}

  @override
  void update(double dt) {
    super.update(dt);
    final x = _x;
    if (x == null) {
      _wait -= dt;
      if (_wait <= 0) {
        _dir = random.nextBool() ? 1 : -1;
        _x = _dir > 0 ? area.left - 80 : area.right + 80;
        _y = area.top + random.nextDouble() * area.height;
        _speed = 180 + random.nextDouble() * 120;
        if (random.nextDouble() < 0.6) sound('gull_cry');
      }
      return;
    }
    final next = x + _dir * _speed * dt;
    if (next < area.left - 100 || next > area.right + 100) {
      _x = null;
      _wait = 5 + random.nextDouble() * 10;
    } else {
      _x = next;
    }
  }

  @override
  void render(Canvas canvas) {
    final x = _x;
    if (x == null) return;
    final y = _y + math.sin(time * 1.5) * 12;
    final flap = math.sin(time * 7) * 14;
    canvas.drawPath(
      Path()
        ..moveTo(x - 30, y - flap)
        ..quadraticBezierTo(x - 12, y - 10 - flap * 0.3, x, y)
        ..quadraticBezierTo(x + 12, y - 10 - flap * 0.3, x + 30, y - flap),
      Paint()
        ..color = const Color(0xE6E6E8E4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }
}

// ---------------------------------------------------------------------------
// Fulmar: sits on a ledge, flies off when startled, glides back. A raven
// does the same from a branch, in black.

class _Fulmar extends Creature {
  _Fulmar(super.area, super.random, super.sound, {this.raven = false});

  final bool raven;

  Color get _body => raven ? const Color(0xFF16161A) : const Color(0xFFDADDDA);
  Color get _wing => raven ? const Color(0xFF2A2A32) : const Color(0xFF8C9296);
  Color get _head => raven ? const Color(0xFF16161A) : const Color(0xFFE4E6E4);
  Color get _eye => raven ? const Color(0xFF8A8A92) : const Color(0xFF111111);
  Color get _beak => raven ? const Color(0xFF24242A) : const Color(0xFF9A8A5A);

  /// Seconds into an absence, or -1 while sitting.
  double _away = -1;
  static const _flyOff = 1.6;
  static const _absence = 10.0;
  static const _return = 2.0;

  Offset get _seat => Offset(area.center.dx, area.bottom);

  @override
  bool near(Offset p) => _away < 0 && (p - _seat).distance < 80;

  @override
  void startle() {
    if (_away >= 0) return;
    _away = 0;
    sound('wings_flutter');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_away >= 0) {
      _away += dt;
      if (_away > _flyOff + _absence + _return) _away = -1;
    }
  }

  @override
  void render(Canvas canvas) {
    final seat = _seat;
    final away = _away;
    if (away < 0) {
      final bob = math.sin(time * 1.1) * 1.5;
      canvas
        ..drawOval(
          Rect.fromCenter(
            center: seat + Offset(0, -14 + bob),
            width: 40,
            height: 24,
          ),
          Paint()..color = _body,
        )
        ..drawOval(
          Rect.fromCenter(
            center: seat + Offset(-8, -18 + bob),
            width: 26,
            height: 14,
          ),
          Paint()..color = _wing,
        )
        ..drawCircle(seat + Offset(16, -26 + bob), 9, Paint()..color = _head)
        ..drawCircle(seat + Offset(19, -28 + bob), 1.6, Paint()..color = _eye)
        ..drawLine(
          seat + Offset(24, -25 + bob),
          seat + Offset(31, -24 + bob),
          Paint()
            ..color = _beak
            ..strokeWidth = raven ? 4 : 3,
        );
      return;
    }
    // Flying off (or gliding back), wings out.
    final Offset pos;
    if (away < _flyOff) {
      pos = _lerp(seat, seat + const Offset(260, -220), away / _flyOff);
    } else if (away < _flyOff + _absence) {
      return;
    } else {
      final t = (away - _flyOff - _absence) / _return;
      pos = _lerp(
        seat + const Offset(-280, -160),
        seat + const Offset(0, -16),
        t,
      );
    }
    final flap = math.sin(time * 9) * 8;
    canvas.drawPath(
      Path()
        ..moveTo(pos.dx - 34, pos.dy - flap)
        ..quadraticBezierTo(pos.dx - 12, pos.dy - 6, pos.dx, pos.dy)
        ..quadraticBezierTo(
          pos.dx + 12,
          pos.dy - 6,
          pos.dx + 34,
          pos.dy - flap,
        ),
      Paint()
        ..color = _body
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }
}

// ---------------------------------------------------------------------------
// Heron: a great blue heron standing in the shallows on long legs, its
// neck folded; now and then it leans and strikes at the water. Startled,
// it lifts off slowly on broad wings and comes back later.

class _Heron extends Creature {
  _Heron(super.area, super.random, super.sound) {
    _nextStrike = 4 + random.nextDouble() * 6;
  }

  static const _grey = Color(0xFF7A8A9A);
  static const _dark = Color(0xFF4A5462);
  static const _pale = Color(0xFFD8DCE0);
  static const _bill = Color(0xFFC8A040);

  double _away = -1;
  static const _flyOff = 2.4;
  static const _absence = 12.0;
  static const _return = 3.0;

  double _nextStrike = 0;
  double _strike = -1;

  Offset get _feet => Offset(area.center.dx, area.bottom);

  @override
  bool near(Offset p) =>
      _away < 0 && (p - _feet.translate(0, -60)).distance < 110;

  @override
  void startle() {
    if (_away >= 0) return;
    _away = 0;
    sound('wings_flutter');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_away >= 0) {
      _away += dt;
      if (_away > _flyOff + _absence + _return) _away = -1;
      return;
    }
    if (_strike >= 0) {
      _strike += dt;
      if (_strike > 1.2) _strike = -1;
    } else {
      _nextStrike -= dt;
      if (_nextStrike <= 0) {
        _strike = 0;
        _nextStrike = 6 + random.nextDouble() * 9;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final away = _away;
    if (away >= 0) {
      final Offset pos;
      if (away < _flyOff) {
        pos = _lerp(_feet, _feet + const Offset(-320, -260), away / _flyOff);
      } else if (away < _flyOff + _absence) {
        return;
      } else {
        final t = (away - _flyOff - _absence) / _return;
        pos = _lerp(_feet + const Offset(340, -240), _feet, t);
      }
      final flap = math.sin(time * 4) * 14;
      canvas
        ..drawPath(
          Path()
            ..moveTo(pos.dx - 60, pos.dy - 70 - flap)
            ..quadraticBezierTo(pos.dx - 20, pos.dy - 82, pos.dx, pos.dy - 70)
            ..quadraticBezierTo(
              pos.dx + 20,
              pos.dy - 82,
              pos.dx + 60,
              pos.dy - 70 - flap,
            ),
          Paint()
            ..color = _dark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..strokeCap = StrokeCap.round,
        )
        ..drawLine(
          pos.translate(0, -70),
          pos.translate(-40, -66),
          Paint()
            ..color = _grey
            ..strokeWidth = 4,
        );
      return;
    }
    final f = _feet;
    final lean = _strike < 0
        ? 0.0
        : math.sin(math.min(1, _strike / 1.2) * math.pi);
    final legs = Paint()
      ..color = const Color(0xFF5A5040)
      ..strokeWidth = 3;
    // Ripples round its legs, then the legs, the body, the neck and bill.
    canvas
      ..drawOval(
        Rect.fromCenter(center: f, width: 70, height: 10),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x66FFFFFF),
      )
      ..drawLine(f.translate(-6, 0), f.translate(-4, -70), legs)
      ..drawLine(f.translate(6, 0), f.translate(4, -70), legs);
    final body = f.translate(0, -88);
    canvas
      ..drawOval(
        Rect.fromCenter(center: body, width: 76, height: 34),
        Paint()..color = _grey,
      )
      ..drawOval(
        Rect.fromCenter(center: body.translate(-8, -4), width: 50, height: 18),
        Paint()..color = _dark,
      );
    final neckBase = body.translate(26, -10);
    final head = Offset.lerp(
      neckBase.translate(10, -54),
      neckBase.translate(40, 40),
      lean,
    )!;
    canvas
      ..drawPath(
        Path()
          ..moveTo(neckBase.dx, neckBase.dy)
          ..quadraticBezierTo(
            neckBase.dx - 14 + lean * 20,
            neckBase.dy - 26 + lean * 30,
            head.dx,
            head.dy,
          ),
        Paint()
          ..color = _pale
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(head, 7, Paint()..color = _pale)
      ..drawLine(
        head.translate(2, -3),
        head.translate(-6, -5),
        Paint()
          ..color = const Color(0xFF2A2A30)
          ..strokeWidth = 3,
      )
      ..drawLine(
        head.translate(5, 1),
        head.translate(28, 4 + lean * 14),
        Paint()
          ..color = _bill
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
  }
}

// ---------------------------------------------------------------------------
// Seal: a bearded seal hauled out on a floe, lying long, now and then
// raising its head; startled, it slides off into the water and is gone a
// while, then hauls out again.

class _Seal extends Creature {
  _Seal(super.area, super.random, super.sound) {
    _nextLook = 3 + random.nextDouble() * 5;
  }

  static const _body = Color(0xFF6A6058);
  static const _belly = Color(0xFF8A8076);
  static const _dark = Color(0xFF3A3430);

  double _away = -1;
  static const _slide = 1.0;
  static const _absence = 12.0;
  static const _haul = 1.6;

  double _nextLook = 0;
  double _look = -1;

  Offset get _rest => Offset(area.center.dx, area.bottom);

  @override
  bool near(Offset p) =>
      _away < 0 && (p - _rest.translate(0, -20)).distance < 110;

  @override
  void startle() {
    if (_away >= 0) return;
    _away = 0;
    sound('splash');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_away >= 0) {
      _away += dt;
      if (_away > _slide + _absence + _haul) _away = -1;
      return;
    }
    if (_look >= 0) {
      _look += dt;
      if (_look > 2.5) _look = -1;
    } else {
      _nextLook -= dt;
      if (_nextLook <= 0) {
        _look = 0;
        _nextLook = 5 + random.nextDouble() * 8;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final away = _away;
    var offset = Offset.zero;
    var opacity = 1.0;
    if (away >= 0) {
      if (away < _slide) {
        final t = away / _slide;
        offset = Offset(-90 * t, 26 * t);
        opacity = 1 - t;
      } else if (away < _slide + _absence) {
        // Its head now and then in the water off the floe.
        final t = (away - _slide) / _absence;
        if (t > 0.3 && t < 0.6) {
          canvas.drawCircle(
            _rest.translate(-150, 24),
            9,
            Paint()..color = _dark,
          );
        }
        return;
      } else {
        final t = (away - _slide - _absence) / _haul;
        offset = Offset(-90 * (1 - t), 26 * (1 - t));
        opacity = t;
      }
    }
    final p = _rest + offset;
    final lift = _look < 0 ? 0.0 : math.sin(math.min(1, _look / 2.5) * math.pi);
    final a = (opacity * 255).round();
    canvas
      ..drawOval(
        Rect.fromCenter(center: p.translate(0, -2), width: 150, height: 14),
        Paint()..color = Color.fromARGB((a * 0.25).round(), 0, 0, 0),
      )
      ..drawOval(
        Rect.fromCenter(center: p.translate(0, -20), width: 140, height: 38),
        Paint()..color = _body.withAlpha(a),
      )
      ..drawOval(
        Rect.fromCenter(center: p.translate(4, -10), width: 110, height: 14),
        Paint()..color = _belly.withAlpha(a),
      );
    // Hind flippers, and the head with its whiskers.
    canvas.drawPath(
      Path()
        ..moveTo(p.dx - 66, p.dy - 22)
        ..lineTo(p.dx - 92, p.dy - 34)
        ..lineTo(p.dx - 90, p.dy - 12)
        ..close(),
      Paint()..color = _dark.withAlpha(a),
    );
    final head = p.translate(70, -30 - lift * 22);
    canvas
      ..drawCircle(head, 17, Paint()..color = _body.withAlpha(a))
      ..drawCircle(
        head.translate(8, -4),
        2.5,
        Paint()..color = _dark.withAlpha(a),
      );
    final whisker = Paint()
      ..strokeWidth = 1.2
      ..color = Color.fromARGB((a * 0.8).round(), 230, 226, 214);
    for (var k = -1; k <= 1; k++) {
      canvas.drawLine(
        head.translate(14, 6),
        head.translate(30, 6 + k * 6.0),
        whisker,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Swifts: small dark birds wheeling over their area in wide, uneven loops,
// wings flicking; tapped among them, they scatter wide and wheel back.

class _Swifts extends Creature {
  _Swifts(super.area, super.random, super.sound) {
    for (var i = 0; i < 5; i++) {
      _phase.add(random.nextDouble() * math.pi * 2);
      _speed.add(0.7 + random.nextDouble() * 0.6);
      _radius.add(0.5 + random.nextDouble() * 0.5);
    }
  }

  final _phase = <double>[];
  final _speed = <double>[];
  final _radius = <double>[];
  double _scatter = 0;

  Offset _at(int i) {
    final t = time * _speed[i] + _phase[i];
    final spread = 1 + _scatter * 1.5;
    return area.center +
        Offset(
          math.cos(t) * area.width * 0.45 * _radius[i] * spread,
          math.sin(t * 1.7) * area.height * 0.4 * _radius[i] * spread,
        );
  }

  @override
  bool near(Offset p) =>
      _scatter <= 0 &&
      [
        for (var i = 0; i < _phase.length; i++) _at(i),
      ].any((b) => (b - p).distance < 70);

  @override
  void startle() {
    if (_scatter > 0) return;
    _scatter = 1;
    sound('wings_flutter');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_scatter > 0) _scatter = math.max(0, _scatter - dt * 0.25);
  }

  @override
  void render(Canvas canvas) {
    final wing = Paint()
      ..color = const Color(0xFF1E1E22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _phase.length; i++) {
      final p = _at(i);
      final flick = math.sin(time * 14 + i) * 5;
      canvas.drawPath(
        Path()
          ..moveTo(p.dx - 16, p.dy - 2 - flick)
          ..quadraticBezierTo(p.dx - 6, p.dy - 6, p.dx, p.dy)
          ..quadraticBezierTo(p.dx + 6, p.dy - 6, p.dx + 16, p.dy - 2 - flick),
        wing,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Grass: winter tufts bending in the wind.

class _Grass extends Creature {
  _Grass(super.area, super.random, super.sound) {
    final count = (area.width / 12).clamp(4, 60).round();
    for (var i = 0; i < count; i++) {
      _blades.add((
        x: area.left + random.nextDouble() * area.width,
        h: area.height * (0.5 + random.nextDouble() * 0.5),
        shade: random.nextDouble(),
      ));
    }
  }

  final List<({double x, double h, double shade})> _blades = [];

  @override
  bool near(Offset p) => false;

  @override
  void startle() {}

  @override
  void render(Canvas canvas) {
    // Gusts come and go across the tufts.
    final gust = 0.5 + 0.5 * math.sin(time * 0.7);
    for (final b in _blades) {
      final sway =
          (math.sin(time * 2.1 + b.x * 0.04) * 0.25 + 0.35 * gust) * b.h;
      final base = Offset(b.x, area.bottom);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(
            base.dx + sway * 0.3,
            base.dy - b.h * 0.6,
            base.dx + sway,
            base.dy - b.h,
          ),
        Paint()
          ..color = Color.lerp(
            const Color(0xFF4E5A3A),
            const Color(0xFF8A7F55),
            b.shade,
          )!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Eagle: circles slowly on broad, still wings, high over a gorge; now and
// then it cries.

class _Eagle extends Creature {
  _Eagle(super.area, super.random, super.sound)
    : _phase = random.nextDouble() * math.pi * 2 {
    _nextCry = 8 + random.nextDouble() * 20;
  }

  final double _phase;
  late double _nextCry;

  /// Radians a second round its circle.
  static const _turn = 0.22;

  double get _angle => _phase + time * _turn;

  Offset get _pos =>
      area.center +
      Offset(
        math.cos(_angle) * area.width / 2,
        math.sin(_angle) * area.height / 2,
      );

  @override
  bool near(Offset p) => false;

  @override
  void startle() {}

  @override
  void update(double dt) {
    super.update(dt);
    _nextCry -= dt;
    if (_nextCry <= 0) {
      sound('eagle_cry');
      _nextCry = 25 + random.nextDouble() * 30;
    }
  }

  @override
  void render(Canvas canvas) {
    final p = _pos;
    // Nearer (lower on its circle) looks a little larger; the wings tilt
    // with the turn.
    final depth = 0.8 + 0.2 * math.sin(_angle);
    final bank = math.cos(_angle) * 0.25;
    final flap = math.sin(time * 1.1) > 0.97 ? math.sin(time * 18) * 4 : 0.0;
    final body = Paint()..color = const Color(0xE62A2420);
    canvas
      ..save()
      ..translate(p.dx, p.dy)
      ..rotate(bank)
      ..scale(depth);
    // Broad wings, fingered at the tips.
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(0, -2)
        ..quadraticBezierTo(side * 18, -8 - flap, side * 40, -5 - flap)
        ..lineTo(side * 44, -1 - flap)
        ..lineTo(side * 40, 1 - flap)
        ..lineTo(side * 43, 3 - flap)
        ..lineTo(side * 37, 4 - flap)
        ..quadraticBezierTo(side * 18, 5, 0, 5)
        ..close();
      canvas.drawPath(wing, body);
    }
    canvas
      // The head, and the fanned tail.
      ..drawOval(
        Rect.fromCenter(center: const Offset(0, -6), width: 7, height: 8),
        body,
      )
      ..drawPath(
        Path()
          ..moveTo(-4, 4)
          ..lineTo(-7, 14)
          ..lineTo(7, 14)
          ..lineTo(4, 4)
          ..close(),
        body,
      )
      ..restore();
  }
}
