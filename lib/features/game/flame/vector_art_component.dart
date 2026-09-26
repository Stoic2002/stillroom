import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/art/vector_art.dart';

/// Draws code-drawn art in the Flame scene. The drawing is rendered once
/// into an image when the scene loads; each frame then draws that image,
/// instead of replaying every path, gradient, and blur (NFR-01).
class VectorArtComponent extends PositionComponent {
  VectorArtComponent(this.painter, {super.position, super.size});

  final ArtPainter painter;
  Image? _image;

  /// Rendered at this many pixels per logical pixel. The scene is 1920
  /// logical pixels wide, about a phone's width in landscape, so 1 is
  /// sharp enough.
  static const resolution = 1.0;

  static final _paint = Paint()..filterQuality = FilterQuality.medium;

  @override
  Future<void> onLoad() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)..scale(resolution);
    painter(canvas, size.toSize());
    final picture = recorder.endRecording();
    _image = await picture.toImage(
      (size.x * resolution).ceil().clamp(1, 4096),
      (size.y * resolution).ceil().clamp(1, 4096),
    );
    picture.dispose();
  }

  @override
  void render(Canvas canvas) {
    final image = _image;
    if (image == null) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size.toSize(),
      _paint,
    );
  }

  @override
  void onRemove() {
    _image?.dispose();
    _image = null;
    super.onRemove();
  }
}
