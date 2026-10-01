import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `darkroom`: frames from a roll of film to be printed. For each frame a
/// test strip shows it in bands of doubling exposure; the player picks the
/// band to print at. The right one prints clean; shorter comes out grey,
/// longer black, and the paper is spoiled. Solved when every frame is
/// printed right.
///
/// ```json
/// "config": {
///   "strip": [2, 4, 8, 16, 32],
///   "frames": [
///     { "image": "images/objects/ep/frame_1.png",
///       "captionKey": "ep.frame.1", "exposure": 2 }
///   ]
/// }
/// ```
/// `strip` gives the bands' exposures in seconds (3 to 7 of them, rising);
/// each frame's `exposure` is the index of its right band, never the first
/// or the last (so a print can always be too light or too dark). 1 to 6
/// frames; the last is the roll's last.
final class DarkroomType implements PuzzleType {
  const DarkroomType();

  static const typeId = 'darkroom';

  @override
  String get id => typeId;

  @override
  DarkroomConfig parseConfig(JsonReader json) {
    json.allowOnly({'strip', 'frames'});
    final strip = json.numbers('strip');
    if (strip.length < 3 || strip.length > 7) {
      json.fail('need 3 to 7 bands', 'strip');
    }
    for (var k = 0; k < strip.length; k++) {
      if (strip[k] <= 0 || (k > 0 && strip[k] <= strip[k - 1])) {
        json.fail('rising exposures above 0', 'strip[$k]');
      }
    }
    final frames = [
      for (final f in json.objects('frames'))
        () {
          f.allowOnly({'image', 'captionKey', 'exposure'});
          final exposure = f.integer('exposure');
          if (exposure < 1 || exposure > strip.length - 2) {
            f.fail('from 1 to ${strip.length - 2}', 'exposure');
          }
          return DarkroomFrame(
            image: f.string('image'),
            captionKey: f.string('captionKey'),
            exposure: exposure,
          );
        }(),
    ];
    if (frames.isEmpty || frames.length > 6) {
      json.fail('need 1 to 6 frames', 'frames');
    }
    return DarkroomConfig(strip: strip, frames: frames);
  }
}

final class DarkroomFrame {
  const DarkroomFrame({
    required this.image,
    required this.captionKey,
    required this.exposure,
  });

  /// Path relative to `assets/`: the frame as printed right.
  final String image;
  final String captionKey;

  /// The index of the band it prints right at.
  final int exposure;
}

final class DarkroomConfig implements PuzzleConfig {
  DarkroomConfig({
    required List<double> strip,
    required List<DarkroomFrame> frames,
  }) : strip = List.unmodifiable(strip),
       frames = List.unmodifiable(frames);

  final List<double> strip;
  final List<DarkroomFrame> frames;

  DarkroomState start() => DarkroomState(this, const {}, null, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final f in frames) ...[
      ContentRef.image(f.image),
      ContentRef.text(f.captionKey),
    ],
  ];
}

final class DarkroomState {
  DarkroomState(this.config, Set<int> printed, this.spoiled, this.mistakes)
    : printed = Set.unmodifiable(printed);

  final DarkroomConfig config;

  /// Frames printed right.
  final Set<int> printed;

  /// The last spoiled print: (frame, band), until the next print.
  final (int, int)? spoiled;
  final int mistakes;

  bool get isSolved => printed.length == config.frames.length;

  /// How a print of [frame] at [band] comes out: below 0 too light, 0
  /// right, above 0 too dark (in doublings).
  int tone(int frame, int band) => band - config.frames[frame].exposure;

  /// Prints [frame] at [band].
  DarkroomState print(int frame, int band) {
    if (isSolved || printed.contains(frame)) return this;
    if (tone(frame, band) == 0) {
      return DarkroomState(config, {...printed, frame}, null, mistakes);
    }
    return DarkroomState(config, printed, (frame, band), mistakes + 1);
  }
}
