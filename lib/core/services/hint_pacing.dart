/// How long the candle for a hint burns before the hint may be read
/// (PRD FR-08; docs/stillroom_frame.md: hints come slower on higher shelves).
///
/// A wait counts the time spent on the hint's stage or puzzle since its
/// previous hint was read, or since the player first got there.
final class HintPacing {
  const HintPacing({
    this.waits = const [
      Duration(seconds: 45),
      Duration(seconds: 90),
      Duration(seconds: 150),
    ],
    this.perShelf = 0.5,
  });

  /// Waits for hint level 1, 2, 3 on the bottom shelf; later levels reuse
  /// the last one.
  final List<Duration> waits;

  /// Extra wait for each shelf above the first, as a fraction of the base
  /// (0.5: shelf II waits 1.5×, shelf III 2×).
  final double perShelf;

  /// The wait before hint [level] (1-based) of a tale on [shelf].
  Duration waitFor({required int level, required int shelf}) {
    final base = waits[(level - 1).clamp(0, waits.length - 1)];
    return base * (1 + perShelf * (shelf - 1).clamp(0, 99));
  }
}
