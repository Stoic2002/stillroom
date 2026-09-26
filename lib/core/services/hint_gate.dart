/// Decides whether the player may reveal a hint (PRD FR-08). Monetization is
/// deferred, so v1 ships [FreeHintGate]; an ad- or purchase-based gate can
/// replace it later without touching the game rules.
abstract interface class HintGate {
  /// Resolves to `true` when the hint may be shown.
  Future<bool> unlock(HintUnlockRequest request);
}

final class HintUnlockRequest {
  const HintUnlockRequest({
    required this.episodeId,
    required this.groupKey,
    required this.level,
  });

  final String episodeId;

  /// `puzzle:<id>` or `stage:<id>`.
  final String groupKey;

  /// 1-based: 1 = vague, 3 = the solution.
  final int level;
}

/// Always allows hints.
final class FreeHintGate implements HintGate {
  const FreeHintGate();

  @override
  Future<bool> unlock(HintUnlockRequest request) async => true;
}
