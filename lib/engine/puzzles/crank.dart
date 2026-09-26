import 'dart:math' as math;

import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `crank`: wind something by dragging round and round, like the clockwork
/// that turns a lighthouse lens.
///
/// ```json
/// "config": { "turns": 4, "clockwise": true, "image": "images/..." }
/// ```
/// `turns` full circles are needed (default 3). A ratchet holds the winding:
/// turning the wrong way does nothing. `image` (optional) is the drum or
/// wheel drawn under the handle.
final class CrankType implements PuzzleType {
  const CrankType();

  static const typeId = 'crank';

  @override
  String get id => typeId;

  @override
  CrankConfig parseConfig(JsonReader json) {
    json.allowOnly({'turns', 'clockwise', 'image'});
    final turns = json.optionalNumber('turns') ?? 3;
    if (turns <= 0 || turns > 20) {
      json.fail('must be above 0, at most 20', 'turns');
    }
    return CrankConfig(
      turns: turns,
      clockwise: json.optionalBool('clockwise') ?? true,
      image: json.optionalString('image'),
    );
  }
}

final class CrankConfig implements PuzzleConfig {
  const CrankConfig({this.turns = 3, this.clockwise = true, this.image});

  final double turns;
  final bool clockwise;
  final String? image;

  CrankState start() => CrankState(this, 0);

  @override
  Iterable<ContentRef> get references => [
    if (image case final image?) ContentRef.image(image),
  ];
}

final class CrankState {
  const CrankState(this.config, this.wound);

  final CrankConfig config;

  /// Radians wound so far, in the right direction.
  final double wound;

  double get progress => (wound / (config.turns * 2 * math.pi)).clamp(0.0, 1.0);

  bool get isSolved => progress >= 1;

  /// The handle moved by [radians] (positive = clockwise on screen). The
  /// wrong way is held by the ratchet.
  CrankState turn(double radians) {
    final forward = config.clockwise ? radians : -radians;
    if (forward <= 0 || isSolved) return this;
    return CrankState(config, wound + forward);
  }
}
