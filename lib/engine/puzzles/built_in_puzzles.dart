import 'beam_sweep.dart';
import 'beat.dart';
import 'casing.dart';
import 'cipher.dart';
import 'clock_hands.dart';
import 'code_lock.dart';
import 'compose.dart';
import 'courses.dart';
import 'crank.dart';
import 'darkroom.dart';
import 'deduction.dart';
import 'dip.dart';
import 'dividers.dart';
import 'hands.dart';
import 'identify.dart';
import 'keyring.dart';
import 'margins.dart';
import 'mudra.dart';
import 'overlay.dart';
import 'pour.dart';
import 'puzzle_type.dart';
import 'quire.dart';
import 'raking_light.dart';
import 'resonance.dart';
import 'reveal.dart';
import 'rings.dart';
import 'roster.dart';
import 'rotary_align.dart';
import 'scan.dart';
import 'sequence.dart';
import 'slot_placement.dart';
import 'snowpit.dart';
import 'sonar.dart';
import 'sources.dart';
import 'spectrum.dart';
import 'still.dart';
import 'strand.dart';
import 'strata.dart';
import 'streets.dart';
import 'swell.dart';
import 'thread.dart';
import 'unwatched.dart';

/// Registers the built-in puzzle types (PRD FR-04, plus `deduction`,
/// `reveal`, `crank`, `overlay`, `clockHands`, `thread`, `rakingLight`,
/// `beamSweep`, `swell`, `roster`, `keyring`, `cipher`, `sources`, `pour`,
/// `resonance`, `beat`, `unwatched`, `compose`, `strand`, `scan`, `quire`,
/// `dip`, `courses`, `identify`, `snowpit`, `darkroom`, `strata`,
/// `streets`, `rings`, `dividers`, `margins`, `sonar`, `mudra`, `casing`,
/// `hands`, `still` and `spectrum`) into [registry].
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
    ..register(const ComposeType())
    ..register(const StrandType())
    ..register(const ScanType())
    ..register(const QuireType())
    ..register(const DipType())
    ..register(const CoursesType())
    ..register(const IdentifyType())
    ..register(const SnowpitType())
    ..register(const DarkroomType())
    ..register(const StrataType())
    ..register(const StreetsType())
    ..register(const RingsType())
    ..register(const DividersType())
    ..register(const MarginsType())
    ..register(const SonarType())
    ..register(const MudraType())
    ..register(const CasingType())
    ..register(const HandsType())
    ..register(const StillType())
    ..register(const SpectrumType());
}
