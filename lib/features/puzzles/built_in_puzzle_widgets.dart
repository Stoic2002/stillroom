import '../../engine/engine.dart';
import 'beam_sweep/beam_sweep_view.dart';
import 'beat/beat_view.dart';
import 'casing/casing_view.dart';
import 'cipher/cipher_view.dart';
import 'clock_hands/clock_hands_view.dart';
import 'code_lock/code_lock_view.dart';
import 'compose/compose_view.dart';
import 'courses/courses_view.dart';
import 'crank/crank_view.dart';
import 'darkroom/darkroom_view.dart';
import 'deduction/deduction_view.dart';
import 'dip/dip_view.dart';
import 'dividers/dividers_view.dart';
import 'identify/identify_view.dart';
import 'keyring/keyring_view.dart';
import 'margins/margins_view.dart';
import 'mudra/mudra_view.dart';
import 'overlay/overlay_view.dart';
import 'pour/pour_view.dart';
import 'puzzle_view.dart';
import 'quire/quire_view.dart';
import 'raking_light/raking_light_view.dart';
import 'resonance/resonance_view.dart';
import 'reveal/reveal_view.dart';
import 'rings/rings_view.dart';
import 'roster/roster_view.dart';
import 'rotary_align/rotary_align_view.dart';
import 'scan/scan_view.dart';
import 'sequence/sequence_view.dart';
import 'slot_placement/slot_placement_view.dart';
import 'snowpit/snowpit_view.dart';
import 'sonar/sonar_view.dart';
import 'sources/sources_view.dart';
import 'strand/strand_view.dart';
import 'strata/strata_view.dart';
import 'streets/streets_view.dart';
import 'swell/swell_view.dart';
import 'thread/thread_view.dart';
import 'unwatched/unwatched_view.dart';

/// Widgets for the built-in puzzle types (PRD FR-04, plus `deduction`,
/// `reveal`, `crank`, `overlay`, `clockHands`, `thread`, `rakingLight`,
/// `beamSweep`, `swell`, `roster`, `keyring`, `cipher`, `sources`, `pour`,
/// `resonance`, `beat`, `unwatched`, `compose`, `strand`, `scan`, `quire`,
/// `dip`, `courses`, `identify`, `snowpit`, `darkroom`, `strata`,
/// `streets`, `rings`, `dividers`, `margins`, `sonar`, `mudra` and
/// `casing`).
PuzzleWidgetRegistry builtInPuzzleWidgets() => PuzzleWidgetRegistry()
  ..register(CodeLockType.typeId, CodeLockView.new)
  ..register(SequenceType.typeId, SequenceView.new)
  ..register(RotaryAlignType.typeId, RotaryAlignView.new)
  ..register(SlotPlacementType.typeId, SlotPlacementView.new)
  ..register(DeductionType.typeId, DeductionView.new)
  ..register(RevealType.typeId, RevealView.new)
  ..register(CrankType.typeId, CrankView.new)
  ..register(OverlayType.typeId, OverlayView.new)
  ..register(ClockHandsType.typeId, ClockHandsView.new)
  ..register(ThreadType.typeId, ThreadView.new)
  ..register(RakingLightType.typeId, RakingLightView.new)
  ..register(BeamSweepType.typeId, BeamSweepView.new)
  ..register(SwellType.typeId, SwellView.new)
  ..register(RosterType.typeId, RosterView.new)
  ..register(KeyringType.typeId, KeyringView.new)
  ..register(CipherType.typeId, CipherView.new)
  ..register(SourcesType.typeId, SourcesView.new)
  ..register(PourType.typeId, PourView.new)
  ..register(ResonanceType.typeId, ResonanceView.new)
  ..register(BeatType.typeId, BeatView.new)
  ..register(UnwatchedType.typeId, UnwatchedView.new)
  ..register(ComposeType.typeId, ComposeView.new)
  ..register(StrandType.typeId, StrandView.new)
  ..register(ScanType.typeId, ScanView.new)
  ..register(QuireType.typeId, QuireView.new)
  ..register(DipType.typeId, DipView.new)
  ..register(CoursesType.typeId, CoursesView.new)
  ..register(IdentifyType.typeId, IdentifyView.new)
  ..register(SnowpitType.typeId, SnowpitView.new)
  ..register(DarkroomType.typeId, DarkroomView.new)
  ..register(StrataType.typeId, StrataView.new)
  ..register(StreetsType.typeId, StreetsView.new)
  ..register(RingsType.typeId, RingsView.new)
  ..register(DividersType.typeId, DividersView.new)
  ..register(MarginsType.typeId, MarginsView.new)
  ..register(SonarType.typeId, SonarView.new)
  ..register(MudraType.typeId, MudraView.new)
  ..register(CasingType.typeId, CasingView.new);
