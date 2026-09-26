import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/art/vector_art.dart';

/// Draws code-drawn art in the Flame scene. The drawing is recorded once
/// into a [Picture] and replayed each frame, so it costs one draw call
/// (NFR-01).
class VectorArtComponent extends PositionComponent {
  VectorArtComponent(this.painter, {super.position, super.size});

  final ArtPainter painter;
  Picture? _picture;

  @override
  Future<void> onLoad() async {
    final recorder = PictureRecorder();
    painter(Canvas(recorder), size.toSize());
    _picture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    final picture = _picture;
    if (picture != null) canvas.drawPicture(picture);
  }

  @override
  void onRemove() {
    _picture?.dispose();
    _picture = null;
    super.onRemove();
  }
}
