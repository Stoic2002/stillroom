import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `rakingLight`: read faint marks by a low light, as archaeologists read
/// worn wax tablets and scratched plaster.
///
/// ```json
/// "config": { "surface": "images/...", "marks": "images/...",
///             "from": 200, "tolerance": 12 }
/// ```
/// The player drags a lamp round the surface. The marks (`marks`) show only
/// as the light grazes them from the right side: `from` is the direction
/// the lamp must shine from, in degrees clockwise from the top (0 = above,
/// 90 = right). Within `tolerance` degrees (default 12) they can be read,
/// and the puzzle is solved. `surface` is the picture under the marks.
final class RakingLightType implements PuzzleType {
  const RakingLightType();

  static const typeId = 'rakingLight';

  @override
  String get id => typeId;

  @override
  RakingLightConfig parseConfig(JsonReader json) {
    json.allowOnly({'surface', 'marks', 'from', 'tolerance'});
    final from = json.number('from');
    if (from < 0 || from >= 360) json.fail('must be 0 to 359', 'from');
    final tolerance = json.optionalNumber('tolerance') ?? 12;
    if (tolerance <= 0 || tolerance > 45) {
      json.fail('must be above 0 and at most 45', 'tolerance');
    }
    return RakingLightConfig(
      surface: json.string('surface'),
      marks: json.string('marks'),
      from: from,
      tolerance: tolerance,
    );
  }
}

final class RakingLightConfig implements PuzzleConfig {
  const RakingLightConfig({
    required this.surface,
    required this.marks,
    required this.from,
    this.tolerance = 12,
  });

  final String surface;
  final String marks;

  /// Degrees clockwise from the top that the light must come from.
  final double from;
  final double tolerance;

  /// The lamp starts opposite the right side, so it has to go round.
  RakingLightState start() => RakingLightState(this, (from + 180) % 360);

  @override
  Iterable<ContentRef> get references => [
    ContentRef.image(surface),
    ContentRef.image(marks),
  ];
}

final class RakingLightState {
  const RakingLightState(this.config, this.lamp);

  final RakingLightConfig config;

  /// Where the lamp is, in degrees clockwise from the top.
  final double lamp;

  /// How far the lamp is from the right side, 0 to 180 degrees.
  double get miss {
    final d = (lamp - config.from).abs() % 360;
    return math.min(d, 360 - d);
  }

  /// How clearly the marks show, 0 (not at all) to 1 (as clear as they get):
  /// they begin to show within three times the tolerance.
  double get clarity {
    final t = config.tolerance;
    if (miss <= t) return 1;
    return (1 - (miss - t) / (2 * t)).clamp(0.0, 1.0);
  }

  bool get isSolved => miss <= config.tolerance;

  RakingLightState moveTo(double degrees) =>
      RakingLightState(config, degrees % 360);
}
