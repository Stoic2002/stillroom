import 'beam_sweep.dart';
import 'beat.dart';
import 'cipher.dart';
import 'clock_hands.dart';
import 'code_lock.dart';
import 'compose.dart';
import 'crank.dart';
import 'deduction.dart';
import 'keyring.dart';
import 'overlay.dart';
import 'pour.dart';
import 'puzzle_type.dart';
import 'raking_light.dart';
import 'resonance.dart';
import 'reveal.dart';
import 'roster.dart';
import 'rotary_align.dart';
import 'sequence.dart';
import 'slot_placement.dart';
import 'sources.dart';
import 'swell.dart';
import 'thread.dart';
import 'unwatched.dart';

/// Registers the built-in puzzle types (PRD FR-04, plus `deduction`,
/// `reveal`, `crank`, `overlay`, `clockHands`, `thread`, `rakingLight`,
/// `beamSweep`, `swell`, `roster`, `keyring`, `cipher`, `sources`, `pour`,
/// `resonance`, `beat`, `unwatched` and `compose`) into
/// [registry].
void registerBuiltInPuzzleTypes(PuzzleTypeRegistry registry) {
  registry
    ..register(const CodeLockType())
    ..register(const SequenceType())
    ..register(const RotaryAlignType())
    ..register(const SlotPlacementType())
    ..register(const DeductionType())
    ..register(const RevealType())
    ..register(const CrankType())
    ..register(const OverlayType())
    ..register(const ClockHandsType())
    ..register(const ThreadType())
    ..register(const RakingLightType())
    ..register(const BeamSweepType())
    ..register(const SwellType())
    ..register(const RosterType())
    ..register(const KeyringType())
    ..register(const CipherType())
    ..register(const SourcesType())
    ..register(const PourType())
    ..register(const ResonanceType())
    ..register(const BeatType())
    ..register(const UnwatchedType())
    ..register(const ComposeType());
}
