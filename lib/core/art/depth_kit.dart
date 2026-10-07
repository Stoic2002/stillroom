import 'dart:ui';

import 'art_kit.dart';

/// One-point perspective for code-drawn scenes: one camera, one vanishing
/// point [vp] (the eye's level and line of sight), and everything (the
/// room's walls and floor, and every object in it) drawn from it, so what
/// stands on the floor meets the floor.
///
/// Positions are in room units: `x` across, from 0 (the left wall) to 1
/// (the right wall); `y` up, from 0 (the floor) to 1 (the ceiling); `z`
/// back, from 0 (the picture's front edge) to 1 (the back wall). At the
/// front the room fills the picture; the back wall is the picture scaled
/// by [depth] about [vp]. Outdoors, the "back wall" is just a depth to
/// measure by: the ground runs on past it to the horizon at `vp.dy`, and
/// `x` may run past 0 and 1.
final class Room {
  Room(this.a, {required this.vp, required this.depth})
    : assert(depth > 0 && depth < 1);

  final Art a;

  /// Where receding lines meet.
  final Offset vp;

  /// How large the back wall is against the picture (0 to 1): smaller is a
  /// deeper room.
  final double depth;

  Size get size => a.size;

  /// The eye's height and place across, in room units.
  double get eyeY => 1 - vp.dy / size.height;
  double get eyeX => vp.dx / size.width;

  /// How large things are at depth [z], against the front edge.
  double scaleAt(double z) => depth / (depth + z * (1 - depth));

  /// The point at ([x], [y], [z]) on screen.
  Offset at(double x, double y, double z) {
    final front = Offset(x * size.width, (1 - y) * size.height);
    return vp + (front - vp) * scaleAt(z);
  }

  /// A point on the floor.
  Offset floorAt(double x, double z) => at(x, 0, z);

  /// The back wall, in pixels.
  Rect get back => Rect.fromPoints(at(0, 1, 1), at(1, 0, 1));

  /// [p] moved [t] of the way towards the vanishing point: the same thing,
  /// further back.
  Offset toward(Offset p, double t) => Offset.lerp(p, vp, t)!;

  Path get floor => a.poly([
    back.bottomLeft,
    back.bottomRight,
    Offset(size.width, size.height),
    Offset(0, size.height),
  ]);

  Path get ceiling =>
      a.poly([Offset.zero, Offset(size.width, 0), back.topRight, back.topLeft]);

  Path get leftWall => a.poly([
    Offset.zero,
    back.topLeft,
    back.bottomLeft,
    Offset(0, size.height),
  ]);

  Path get rightWall => a.poly([
    Offset(size.width, 0),
    Offset(size.width, size.height),
    back.bottomRight,
    back.topRight,
  ]);

  /// The room's four receding edges, where the planes meet.
  void edges(Color color, {double width = 0.5}) {
    for (final (p, q) in [
      (back.topLeft, Offset.zero),
      (back.topRight, Offset(size.width, 0)),
      (back.bottomLeft, Offset(0, size.height)),
      (back.bottomRight, Offset(size.width, size.height)),
    ]) {
      a.line(p, q, color, width: width);
    }
  }

  /// Floor boards or flagstones: [rows] courses receding, [columns] joints
  /// running back to the vanishing point, between [x0] and [x1] and as far
  /// back as [z1].
  void floorGrid(
    Color color, {
    int rows = 7,
    int columns = 9,
    double width = 0.3,
    double x0 = 0,
    double x1 = 1,
    double z1 = 1,
  }) {
    for (var c = 0; c <= columns && columns > 0; c++) {
      final x = x0 + (x1 - x0) * c / columns;
      a.hairline(floorAt(x, 0), floorAt(x, z1), color, width);
    }
    for (var r = 1; r <= rows; r++) {
      final z = z1 * r / (rows + 1);
      a.hairline(floorAt(x0, z), floorAt(x1, z), color, width);
    }
  }

  /// Soft dark where planes meet: the back wall's foot and the room's
  /// corners, so the box of the room reads as a box.
  void shadeCorners({double strength = 0.45}) {
    final dark = Color.fromRGBO(0, 0, 0, strength);
    const clear = Color(0x00000000);
    final u = a.u;
    a.canvas.drawRect(
      Rect.fromLTRB(back.left, back.bottom - u * 6, back.right, back.bottom),
      Paint()
        ..shader = Gradient.linear(
          Offset(0, back.bottom - u * 6),
          Offset(0, back.bottom),
          [clear, dark],
        ),
    );
    for (final (wall, edge, outer) in [
      (leftWall, back.left, 0.0),
      (rightWall, back.right, size.width),
    ]) {
      a.canvas.drawPath(
        wall,
        Paint()
          ..shader = Gradient.linear(Offset(outer, 0), Offset(edge, 0), [
            clear,
            dark,
          ]),
      );
    }
    a.canvas.drawPath(
      floor,
      Paint()
        ..shader = Gradient.linear(
          Offset(0, size.height),
          Offset(0, back.bottom),
          [clear, dark],
        ),
    );
  }

  /// The shadow on the floor under something standing on it, its footprint
  /// [x0]–[x1] by [z0]–[z1]: a soft spread, and a darker core hard against
  /// it, so it sits.
  void shadow(
    double x0,
    double x1,
    double z0,
    double z1, {
    double strength = 0.45,
    double spread = 0.25,
  }) {
    final dx = (x1 - x0) * spread + 0.004;
    final dz = (z1 - z0) * spread + 0.004;
    Path quad(double grow) => a.poly([
      floorAt(x0 - dx * grow, z0 - dz * grow * 0.5),
      floorAt(x1 + dx * grow, z0 - dz * grow * 0.5),
      floorAt(x1 + dx * grow, z1 + dz * grow),
      floorAt(x0 - dx * grow, z1 + dz * grow),
    ]);
    a.canvas
      ..drawPath(
        quad(1),
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, strength * 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.4),
      )
      ..drawPath(
        quad(0.15),
        Paint()
          ..color = Color.fromRGBO(0, 0, 0, strength)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.35),
      );
  }

  /// A solid block from ([x0], [y0], [z0]) to ([x1], [y1], [z1]), with the
  /// faces the eye can see: its front, its top if it is below the eye (or
  /// its underside if above), and the side facing the middle. The top is
  /// lit, the sides shaded. Returns its front face on screen.
  Rect block(
    double x0,
    double x1,
    double y0,
    double y1,
    double z0,
    double z1,
    Color color, {
    double line = 0.5,
    Color? top,
    Color? side,
  }) {
    final topColor = top ?? Color.lerp(color, const Color(0xFFFFFFFF), 0.14)!;
    final sideColor = side ?? Color.lerp(color, Art.outline, 0.3)!;
    if (y1 < eyeY) {
      a.path(
        a.poly([
          at(x0, y1, z0),
          at(x1, y1, z0),
          at(x1, y1, z1),
          at(x0, y1, z1),
        ]),
        topColor,
        line: line,
      );
    } else if (y0 > eyeY) {
      a.path(
        a.poly([
          at(x0, y0, z0),
          at(x1, y0, z0),
          at(x1, y0, z1),
          at(x0, y0, z1),
        ]),
        Color.lerp(color, Art.outline, 0.45)!,
        line: line,
      );
    }
    if (x1 < eyeX) {
      a.path(
        a.poly([
          at(x1, y0, z0),
          at(x1, y1, z0),
          at(x1, y1, z1),
          at(x1, y0, z1),
        ]),
        sideColor,
        line: line,
      );
    } else if (x0 > eyeX) {
      a.path(
        a.poly([
          at(x0, y0, z0),
          at(x0, y1, z0),
          at(x0, y1, z1),
          at(x0, y0, z1),
        ]),
        sideColor,
        line: line,
      );
    }
    final front = Rect.fromPoints(at(x0, y1, z0), at(x1, y0, z0));
    a.box(front, color, line: line);
    return front;
  }

  /// A shallow box given by its front face [front] on screen, its depth
  /// running back [depth] of the way to the vanishing point: for things
  /// fixed flat to the back wall (a shelf, a sill, a board). What stands
  /// on the floor is drawn with [block].
  void box(Rect front, Color color, {double depth = 0.05, double line = 0.5}) {
    final bl = toward(front.bottomLeft, depth);
    final br = toward(front.bottomRight, depth);
    final tl = toward(front.topLeft, depth);
    final tr = toward(front.topRight, depth);
    final top = Color.lerp(color, const Color(0xFFFFFFFF), 0.14)!;
    final side = Color.lerp(color, Art.outline, 0.3)!;
    if (front.top > vp.dy) {
      a.path(a.poly([front.topLeft, front.topRight, tr, tl]), top, line: line);
    } else if (front.bottom < vp.dy) {
      a.path(
        a.poly([front.bottomLeft, front.bottomRight, br, bl]),
        side,
        line: line,
      );
    }
    if (front.right < vp.dx) {
      a.path(
        a.poly([front.topRight, tr, br, front.bottomRight]),
        side,
        line: line,
      );
    } else if (front.left > vp.dx) {
      a.path(
        a.poly([front.topLeft, tl, bl, front.bottomLeft]),
        side,
        line: line,
      );
    }
    a.box(front, color, line: line);
  }

  /// A table or bench: a top of [thickness] at [height], on four square
  /// legs of [leg] set in from its corners, with its shadow. Returns the
  /// top's front face on screen.
  Rect table(
    double x0,
    double x1,
    double z0,
    double z1,
    double height,
    Color color, {
    double thickness = 0.02,
    double leg = 0.012,
    double inset = 0.01,
    Color? legColor,
    Color? top,
    bool shadow = true,
  }) {
    if (shadow) this.shadow(x0, x1, z0, z1, strength: 0.35, spread: 0.08);
    final legs = legColor ?? color;
    final lz = leg * 2.5;
    // The back legs first, then the front, then the top over them.
    for (final z in [z1 - inset - lz, z0 + inset]) {
      for (final x in [x0 + inset, x1 - inset - leg]) {
        footShadow(x + leg / 2, z + lz / 2, leg);
        block(x, x + leg, 0, height - thickness, z, z + lz, legs, line: 0.3);
      }
    }
    return block(x0, x1, height - thickness, height, z0, z1, color, top: top);
  }

  /// A small dark pool on the floor where a leg or a foot meets it.
  void footShadow(double x, double z, double size, {double strength = 0.55}) {
    final c = floorAt(x, z);
    final w = (floorAt(x + size * 1.6, z).dx - floorAt(x - size * 1.6, z).dx)
        .abs();
    a.canvas.drawOval(
      Rect.fromCenter(center: c, width: w, height: w * 0.35),
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 0.3),
    );
  }

  /// A recess in the back wall (a window, a niche): its opening [r], and
  /// the reveal, the inner faces of the wall's thickness, lit on one side.
  void recess(Rect r, Color wall, {double thickness = 0.06}) {
    final inner = recessInner(r, thickness: thickness);
    final light = Color.lerp(wall, const Color(0xFFFFFFFF), 0.12)!;
    final dark = Color.lerp(wall, Art.outline, 0.4)!;
    a
      ..path(
        a.poly([r.topLeft, r.topRight, inner.topRight, inner.topLeft]),
        dark,
        line: 0.4,
      )
      ..path(
        a.poly([
          r.bottomLeft,
          r.bottomRight,
          inner.bottomRight,
          inner.bottomLeft,
        ]),
        light,
        line: 0.4,
      )
      ..path(
        a.poly([r.topLeft, inner.topLeft, inner.bottomLeft, r.bottomLeft]),
        Color.lerp(wall, Art.outline, 0.2)!,
        line: 0.4,
      )
      ..path(
        a.poly([r.topRight, inner.topRight, inner.bottomRight, r.bottomRight]),
        light,
        line: 0.4,
      );
  }

  /// The inner opening of a [recess] at [r].
  static Rect recessInner(Rect r, {double thickness = 0.06}) => Rect.fromPoints(
    Offset.lerp(r.topLeft, r.center, thickness * 4)!,
    Offset.lerp(r.bottomRight, r.center, thickness * 4)!,
  );

  /// A soft shadow on the floor under something standing in [r].
  void contactShadow(Rect r, {double strength = 0.4}) => a.canvas.drawOval(
    r,
    Paint()
      ..color = Color.fromRGBO(0, 0, 0, strength)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.2),
  );

  /// Light falling from a window [from] (two points on its sill) to a
  /// patch [to] on the floor.
  void beam(
    List<Offset> from,
    List<Offset> to,
    Color color, {
    double strength = 0.16,
  }) {
    a.canvas.drawPath(
      a.poly([from[0], from[1], to[1], to[0]]),
      Paint()
        ..shader = Gradient.linear(from[0], to[0], [
          color.withValues(alpha: strength),
          color.withValues(alpha: 0),
        ]),
    );
    a.canvas.drawPath(
      a.poly(to.length == 4 ? to : [to[0], to[1], to[1], to[0]]),
      Paint()
        ..color = color.withValues(alpha: strength * 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, a.u * 1.5),
    );
  }
}
