import 'dart:ui';

import 'art_kit.dart';

/// One-point perspective for code-drawn rooms: a room seen from its open
/// front, its back wall a rectangle, its floor, ceiling and side walls
/// running from the picture's edges to the back wall's edges, every
/// receding line meeting at the vanishing point [vp].
///
/// Objects keep the places their hotspots name: a [box] is given by its
/// front face on screen, and its depth runs back towards [vp].
final class Room {
  Room(this.a, {required this.back, Offset? vp})
    : vp = vp ?? Offset(back.center.dx, back.top + back.height * 0.55);

  final Art a;

  /// The back wall, in pixels.
  final Rect back;

  /// Where receding lines meet: the eye's level and line of sight.
  final Offset vp;

  Size get size => a.size;

  /// [p] moved [t] of the way towards the vanishing point.
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

  /// A point on the floor: [x] from 0 (left wall) to 1 (right wall),
  /// [z] from 0 (the picture's front edge) to 1 (the back wall). Depth is
  /// foreshortened: near rows are wider apart than far ones.
  Offset floorAt(double x, double z) {
    final s = back.width / size.width;
    final f = z / (z + (1 - z) / s);
    final left = Offset.lerp(Offset(0, size.height), back.bottomLeft, f)!;
    final right = Offset.lerp(
      Offset(size.width, size.height),
      back.bottomRight,
      f,
    )!;
    return Offset.lerp(left, right, x)!;
  }

  /// Floor boards or flagstones: [rows] courses receding, [columns] joints
  /// running back to the vanishing point.
  void floorGrid(
    Color color, {
    int rows = 7,
    int columns = 9,
    double width = 0.3,
  }) {
    for (var c = 0; c <= columns; c++) {
      final x = c / columns;
      a.hairline(floorAt(x, 0), floorAt(x, 1), color, width);
    }
    for (var r = 1; r <= rows; r++) {
      final z = r / (rows + 1);
      a.hairline(floorAt(0, z), floorAt(1, z), color, width);
    }
  }

  /// Soft dark where planes meet: the back wall's foot and the room's
  /// corners, so the box of the room reads as a box.
  void shadeCorners({double strength = 0.45}) {
    final dark = Color.fromRGBO(0, 0, 0, strength);
    const clear = Color(0x00000000);
    final u = a.u;
    // Along the back wall's foot.
    a.canvas.drawRect(
      Rect.fromLTRB(back.left, back.bottom - u * 6, back.right, back.bottom),
      Paint()
        ..shader = Gradient.linear(
          Offset(0, back.bottom - u * 6),
          Offset(0, back.bottom),
          [clear, dark],
        ),
    );
    // The side walls darken towards the back.
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
    // The floor darkens towards the back wall.
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

  /// A box whose front face is [front]; its depth runs back [depth] of the
  /// way to the vanishing point. Draws the faces the eye can see: the top
  /// when the box is below eye level, the side facing the middle, and the
  /// front. The top is lit, the side shaded.
  void box(
    Rect front,
    Color color, {
    double depth = 0.12,
    double line = 0.5,
    bool shadow = true,
  }) {
    final bl = toward(front.bottomLeft, depth);
    final br = toward(front.bottomRight, depth);
    final tl = toward(front.topLeft, depth);
    final tr = toward(front.topRight, depth);
    if (shadow && front.bottom > vp.dy) {
      contactShadow(
        Rect.fromLTRB(
          front.left - a.u,
          bl.dy - a.u,
          front.right + a.u,
          front.bottom + a.u * 1.4,
        ),
      );
    }
    final top = Color.lerp(color, const Color(0xFFFFFFFF), 0.14)!;
    final side = Color.lerp(color, Art.outline, 0.35)!;
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

  /// A recess in the back wall (a window, a niche): its opening [r], and
  /// the reveal, the inner faces of the wall's thickness, lit on one side.
  void recess(Rect r, Color wall, {double thickness = 0.06}) {
    final inner = Rect.fromPoints(
      Offset.lerp(r.topLeft, r.center, thickness * 4)!,
      Offset.lerp(r.bottomRight, r.center, thickness * 4)!,
    );
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

  /// Light falling from a window [from] (a quad on the back wall) to a
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
