import 'package:flutter/widgets.dart';

import 'alamut_1256_art.dart';
import 'art_kit.dart';
import 'bastille_1703_art.dart';
import 'chongling_1908_art.dart';
import 'dyatlov_1959_art.dart';
import 'flannan_isles_1900_art.dart';
import 'franklin_1845_art.dart';
import 'great_zimbabwe_1871_art.dart';
import 'gyeongju_771_art.dart';
import 'honnoji_1582_art.dart';
import 'lawang_sewu_1945_art.dart';
import 'pompeii_79_art.dart';
import 'roanoke_1590_art.dart';
import 'whitechapel_1888_art.dart';
import 'whitechapel_1891_art.dart';

export 'art_kit.dart' show ArtPainter;

/// Code-drawn stand-in art, keyed by the same asset paths the content uses.
/// Rendering tries, in order: the real file, this art, a labelled
/// placeholder box. Delete an entry (or ship the file) once final art exists.
final Map<String, ArtPainter> _vectorArt = {
  ...whitechapelArt,
  ...lawangSewuArt,
  ...flannanArt,
  ...pompeiiArt,
  ...bastilleArt,
  ...gyeongjuArt,
  ...whitechapel1891Art,
  ...chongling1908Art,
  ...alamut1256Art,
  ...greatZimbabwe1871Art,
  ...dyatlov1959Art,
  ...honnoji1582Art,
  ...roanoke1590Art,
  ...franklin1845Art,
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
