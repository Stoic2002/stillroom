import 'package:flutter/painting.dart';

/// Stillroom's colors (docs/art_style_guide.md): ink, aged paper, oxblood,
/// tarnished brass, gaslight, and fog. UI code uses these names, never raw
/// hex values.
abstract final class StillroomPalette {
  /// Near-black background.
  static const ink = Color(0xFF0E0B09);

  /// Slightly lifted ink for panels.
  static const soot = Color(0xFF17120E);

  /// Dark wood of cabinets and frames.
  static const walnut = Color(0xFF2A1E15);
  static const walnutLight = Color(0xFF3D2C1F);

  /// Aged paper: text boxes, notes, primary text on dark.
  static const paper = Color(0xFFD8C9A8);
  static const paperShade = Color(0xFFB9A883);

  /// Ink written on paper.
  static const inkOnPaper = Color(0xFF2A1F17);

  /// Muted secondary text on dark.
  static const faded = Color(0xFF8C7A5B);

  /// Accents: borders, selection, highlights.
  static const brass = Color(0xFFA88B4A);
  static const gaslight = Color(0xFFE0A84A);

  /// Danger, wrong answers, wax seals.
  static const oxblood = Color(0xFF6B1E1E);
  static const oxbloodBright = Color(0xFF9A2B25);

  /// Cold tone for fog and glass.
  static const fog = Color(0xFF4E5A52);
}
