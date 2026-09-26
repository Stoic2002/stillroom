import 'package:flutter/material.dart';

import '../../../core/art/vector_art.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/placeholder_palette.dart';
import '../../../core/theme/stillroom_palette.dart';

/// A jar on the shelf: glass, cork, murky contents, and a paper label.
/// Drawn in code until [image] art exists.
class Jar extends StatelessWidget {
  const Jar({
    required this.id,
    required this.label,
    required this.assets,
    this.image,
    this.sealed = false,
    this.locked = false,
    this.distilled = false,
    this.series,
    this.onTap,
    super.key,
  });

  static const size = Size(118, 164);

  final String id;
  final String label;
  final String? image;
  final Set<String> assets;

  /// Not available yet: dim, no contents.
  final bool sealed;

  /// On a shelf the player hasn't reached yet: dimmed, with a padlock.
  final bool locked;

  /// Completed: wax seal on the label.
  final bool distilled;

  /// Jars of one series wear a ribbon of the same colour at the neck.
  final String? series;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = image;
    final vector = path == null ? null : vectorArtFor(path);
    final Widget body = path != null && assets.contains('assets/$path')
        ? Image.asset('assets/$path', fit: BoxFit.contain)
        : vector != null
        ? VectorArt(vector)
        : CustomPaint(
            painter: _JarPainter(
              contents: placeholderColor(id, background: false),
              sealed: sealed,
            ),
          );
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: sealed
              ? 0.4
              : locked
              ? 0.55
              : 1,
          child: SizedBox.fromSize(
            size: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: body),
                if (series case final id?)
                  Positioned(
                    top: size.height * 0.13,
                    left: size.width * 0.26,
                    right: size.width * 0.26,
                    child: Container(
                      height: 7,
                      color: placeholderColor(
                        id,
                        background: false,
                      ).withValues(alpha: 1),
                    ),
                  ),
                if (locked)
                  const Positioned(
                    top: 52,
                    child: Icon(
                      Icons.lock_outline,
                      size: 26,
                      color: StillroomPalette.paper,
                    ),
                  ),
                Positioned(
                  bottom: 34,
                  child: Transform.rotate(
                    angle: -0.05,
                    child: _Label(text: label, distilled: distilled),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.distilled});

  final String text;
  final bool distilled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 100),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          color: StillroomPalette.paper,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.serif,
              fontSize: 12,
              height: 1.1,
              color: StillroomPalette.inkOnPaper,
            ),
          ),
        ),
        if (distilled)
          const Positioned(
            right: -8,
            top: -8,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: StillroomPalette.oxblood,
              child: Icon(
                Icons.water_drop,
                size: 10,
                color: StillroomPalette.paper,
              ),
            ),
          ),
      ],
    );
  }
}

class _JarPainter extends CustomPainter {
  _JarPainter({required this.contents, required this.sealed});

  final Color contents;
  final bool sealed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromLTRBAndCorners(
      w * 0.08,
      h * 0.16,
      w * 0.92,
      h * 0.98,
      topLeft: Radius.circular(w * 0.22),
      topRight: Radius.circular(w * 0.22),
      bottomLeft: Radius.circular(w * 0.12),
      bottomRight: Radius.circular(w * 0.12),
    );
    // Murky contents filling the lower two thirds.
    if (!sealed) {
      canvas
        ..save()
        ..clipRRect(body)
        ..drawRect(
          Rect.fromLTRB(0, h * 0.42, w, h),
          Paint()..color = contents.withValues(alpha: 0.75),
        )
        ..drawRect(
          Rect.fromLTRB(0, h * 0.42, w, h * 0.46),
          Paint()..color = StillroomPalette.paper.withValues(alpha: 0.12),
        )
        ..restore();
    }
    // Glass.
    canvas
      ..drawRRect(
        body,
        Paint()..color = StillroomPalette.fog.withValues(alpha: 0.18),
      )
      ..drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = StillroomPalette.paperShade.withValues(alpha: 0.7),
      )
      // Highlight on the glass.
      ..drawLine(
        Offset(w * 0.2, h * 0.3),
        Offset(w * 0.2, h * 0.8),
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = StillroomPalette.paper.withValues(alpha: 0.18),
      )
      // Neck and cork.
      ..drawRect(
        Rect.fromLTRB(w * 0.28, h * 0.08, w * 0.72, h * 0.17),
        Paint()..color = StillroomPalette.walnutLight,
      )
      ..drawRRect(
        RRect.fromLTRBR(w * 0.3, 0, w * 0.7, h * 0.1, const Radius.circular(3)),
        Paint()..color = const Color(0xFF7A5A3A),
      );
  }

  @override
  bool shouldRepaint(_JarPainter old) =>
      old.contents != contents || old.sealed != sealed;
}
