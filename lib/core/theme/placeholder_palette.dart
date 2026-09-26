import 'package:flutter/painting.dart';

/// Stable color per content id for placeholder art (PRD §9A), so the same
/// object keeps its color everywhere and between runs. Hues stay within the
/// game's muted sepia, rust, and moss range so placeholders already read as
/// part of the mood.
Color placeholderColor(String id, {required bool background}) {
  var hash = 0;
  for (final unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  // 0–60° (rust → ochre) or 90–160° (moss → fog green).
  final band = hash % 130;
  final hue = band < 60 ? band.toDouble() : 90 + (band - 60).toDouble();
  return HSVColor.fromAHSV(
    background ? 1 : 0.9,
    hue,
    background ? 0.22 : 0.35,
    background ? 0.14 : 0.42,
  ).toColor();
}
