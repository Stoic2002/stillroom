import 'package:flutter/widgets.dart';

import 'art_kit.dart';
import 'flannan_isles_1900_art.dart';
import 'lawang_sewu_1945_art.dart';
import 'pompeii_79_art.dart';
import 'whitechapel_1888_art.dart';

export 'art_kit.dart' show ArtPainter;

/// Code-drawn stand-in art, keyed by the same asset paths the content uses.
/// Rendering tries, in order: the real file, this art, a labelled
/// placeholder box. Delete an entry (or ship the file) once final art exists.
final Map<String, ArtPainter> _vectorArt = {
  ...whitechapelArt,
  ...lawangSewuArt,
  ...flannanArt,
  ...pompeiiArt,
};

ArtPainter? vectorArtFor(String path) => _vectorArt[path];

/// Paints an [ArtPainter] in the Flutter tree.
class VectorArt extends StatelessWidget {
  const VectorArt(this.painter, {super.key});

  final ArtPainter painter;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _Painter(painter), size: Size.infinite),
  );
}

class _Painter extends CustomPainter {
  _Painter(this.art);

  final ArtPainter art;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    art(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Painter old) => old.art != art;
}
