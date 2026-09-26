import 'package:flutter/material.dart';

import '../art/vector_art.dart';
import '../theme/placeholder_palette.dart';
import '../theme/stillroom_palette.dart';

/// An image from content (path relative to `assets/`), or a labelled
/// placeholder box while the art does not exist yet (PRD §9A).
class ContentImage extends StatelessWidget {
  const ContentImage({
    required this.path,
    required this.label,
    required this.assets,
    this.background = false,
    super.key,
  });

  final String path;

  /// Shown on the placeholder, usually the content id.
  final String label;

  /// Bundled asset paths (`assets/...`).
  final Set<String> assets;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final asset = 'assets/$path';
    if (assets.contains(asset)) {
      return Image.asset(asset, fit: BoxFit.fill, gaplessPlayback: true);
    }
    final art = vectorArtFor(path);
    if (art != null) return VectorArt(art);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: placeholderColor(label, background: background),
        border: background
            ? null
            : Border.all(
                color: StillroomPalette.paperShade.withValues(alpha: 0.55),
                width: 1.5,
              ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: StillroomPalette.paper,
                fontFamily: 'IMFell',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
