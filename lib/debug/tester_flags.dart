/// Switches for the developer's own test runs on the phone. They are read
/// from `--dart-define` at build time, so a player's build never has them.
library;

/// Every jar opens, whatever has been distilled, so any tale can be checked
/// without finishing the shelves below it. Turn on with
/// `--dart-define=STILLROOM_UNLOCK_ALL=true`.
const bool unlockAllJars = bool.fromEnvironment('STILLROOM_UNLOCK_ALL');
