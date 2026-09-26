import '../json/json_reader.dart';

/// A rectangle in coordinates normalized to the scene image (0–1), so content
/// does not depend on the art's pixel size. JSON form: `[x, y, width, height]`.
final class NormalizedRect {
  const NormalizedRect(this.x, this.y, this.width, this.height);

  factory NormalizedRect.fromJson(JsonReader parent, String key) {
    final v = parent.numbers(key, length: 4);
    if (v[2] <= 0 || v[3] <= 0) {
      parent.fail('width and height must be > 0', key);
    }
    return NormalizedRect(v[0], v[1], v[2], v[3]);
  }

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;
  double get bottom => y + height;

  /// Whether the rect lies fully inside the 0–1 unit square.
  bool get isWithinUnit => x >= 0 && y >= 0 && right <= 1 && bottom <= 1;

  /// Grows the rect around its center to at least [minWidth] × [minHeight].
  NormalizedRect expandedTo(double minWidth, double minHeight) {
    if (width >= minWidth && height >= minHeight) return this;
    final w = width < minWidth ? minWidth : width;
    final h = height < minHeight ? minHeight : height;
    return NormalizedRect(x - (w - width) / 2, y - (h - height) / 2, w, h);
  }

  /// Left/top edges are inclusive, right/bottom exclusive.
  bool contains(double px, double py) =>
      px >= x && px < right && py >= y && py < bottom;

  @override
  bool operator ==(Object other) =>
      other is NormalizedRect &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'NormalizedRect($x, $y, $width, $height)';
}
