import '../json/json_reader.dart';
import '../model/content_ref.dart';
import 'puzzle_type.dart';

/// `spectrum`: a painting looked through with a conservator's lamp tuned
/// along its bands (ultraviolet, the visible, infrared, X-rays). Each band
/// shows one time in the painting's life; tune to it and record the plate.
/// With every plate recorded, lay them in order, the oldest first.
///
/// ```json
/// "config": {
///   "bands": [
///     { "id": "uv", "labelKey": "ep.band.uv", "captionKey": "ep.band.uv_shows",
///       "at": 0.12, "age": 2 }
///   ],
///   "tolerance": 0.05
/// }
/// ```
/// 2 to 6 bands, their `at` (0–1 along the dial) at least twice the
/// `tolerance` apart; `age` 0 (the oldest layer) up, each once.
final class SpectrumType implements PuzzleType {
  const SpectrumType();

  static const typeId = 'spectrum';

  @override
  String get id => typeId;

  @override
  SpectrumConfig parseConfig(JsonReader json) {
    json.allowOnly({'bands', 'tolerance'});
    final tolerance = json.number('tolerance');
    if (tolerance <= 0 || tolerance > 0.2) {
      json.fail('above 0, up to 0.2', 'tolerance');
    }
    final bands = [
      for (final b in json.objects('bands'))
        () {
          b.allowOnly({'id', 'labelKey', 'captionKey', 'at', 'age'});
          final at = b.number('at');
          if (at < 0 || at > 1) b.fail('0 to 1', 'at');
          return SpectrumBand(
            id: b.string('id'),
            labelKey: b.string('labelKey'),
            captionKey: b.string('captionKey'),
            at: at,
            age: b.integer('age'),
          );
        }(),
    ];
    if (bands.length < 2 || bands.length > 6) {
      json.fail('need 2 to 6 bands', 'bands');
    }
    final ages = {for (final b in bands) b.age};
    if (ages.length != bands.length ||
        !ages.every((a) => a >= 0 && a < bands.length)) {
      json.fail('ages 0 to ${bands.length - 1}, each once', 'bands');
    }
    final ids = {for (final b in bands) b.id};
    if (ids.length != bands.length) json.fail('band ids repeat', 'bands');
    final sorted = [...bands]..sort((a, b) => a.at.compareTo(b.at));
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].at - sorted[i - 1].at < tolerance * 2) {
        json.fail('bands too close for the tolerance', 'bands');
      }
    }
    return SpectrumConfig(bands: bands, tolerance: tolerance);
  }
}

final class SpectrumBand {
  const SpectrumBand({
    required this.id,
    required this.labelKey,
    required this.captionKey,
    required this.at,
    required this.age,
  });

  final String id;
  final String labelKey;

  /// What the plate shows, once recorded.
  final String captionKey;

  /// Where on the dial (0–1) the band is clearest.
  final double at;

  /// Its layer's place in the painting's life: 0 the oldest.
  final int age;
}

final class SpectrumConfig implements PuzzleConfig {
  SpectrumConfig({required List<SpectrumBand> bands, required this.tolerance})
    : bands = List.unmodifiable(bands);

  final List<SpectrumBand> bands;
  final double tolerance;

  SpectrumState start() => SpectrumState(this, 0.5, const {}, const [], 0);

  @override
  Iterable<ContentRef> get references => [
    for (final b in bands) ...[
      ContentRef.text(b.labelKey),
      ContentRef.text(b.captionKey),
    ],
  ];
}

/// What recording a plate came to.
enum SpectrumShot { recorded, already, blurred }

final class SpectrumState {
  SpectrumState(
    this.config,
    this.dial,
    Set<int> recorded,
    List<int> laid,
    this.mistakes,
  ) : recorded = Set.unmodifiable(recorded),
      laid = List.unmodifiable(laid);

  final SpectrumConfig config;

  /// Where the lamp is tuned, 0–1.
  final double dial;

  /// Bands whose plates are recorded.
  final Set<int> recorded;

  /// Plates laid in order so far.
  final List<int> laid;
  final int mistakes;

  bool get allRecorded => recorded.length == config.bands.length;
  bool get isSolved => laid.length == config.bands.length;

  /// How clearly band [i] shows at the dial: 1 at its centre, 0 beyond
  /// three tolerances.
  double clarity(int i) {
    final d = (dial - config.bands[i].at).abs() / config.tolerance;
    return d >= 3 ? 0 : (1 - d / 3);
  }

  /// The band the dial is on, if within the tolerance.
  int? get tuned {
    for (var i = 0; i < config.bands.length; i++) {
      if ((dial - config.bands[i].at).abs() <= config.tolerance) return i;
    }
    return null;
  }

  SpectrumState tune(double to) =>
      SpectrumState(config, to.clamp(0, 1), recorded, laid, mistakes);

  /// What recording now would come to.
  SpectrumShot judge() {
    final i = tuned;
    if (i == null) return SpectrumShot.blurred;
    return recorded.contains(i) ? SpectrumShot.already : SpectrumShot.recorded;
  }

  SpectrumState record() {
    final i = tuned;
    if (i == null || recorded.contains(i)) return this;
    return SpectrumState(config, dial, {...recorded, i}, laid, mistakes);
  }

  /// Whether band [i]'s plate is the next to lay (the oldest not yet laid).
  bool fits(int i) =>
      allRecorded && !laid.contains(i) && config.bands[i].age == laid.length;

  /// Lays band [i]'s plate on the stack; a wrong one sends them all back.
  SpectrumState lay(int i) {
    if (!allRecorded || laid.contains(i)) return this;
    if (!fits(i)) {
      return SpectrumState(config, dial, recorded, const [], mistakes + 1);
    }
    return SpectrumState(config, dial, recorded, [...laid, i], mistakes);
  }
}
