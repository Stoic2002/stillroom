import 'clock_hands.dart';
import 'code_lock.dart';
import 'crank.dart';
import 'deduction.dart';
import 'overlay.dart';
import 'puzzle_type.dart';
import 'raking_light.dart';
import 'reveal.dart';
import 'rotary_align.dart';
import 'sequence.dart';
import 'slot_placement.dart';
import 'thread.dart';

/// Registers the built-in puzzle types (PRD FR-04, plus `deduction`,
/// `reveal`, `crank`, `overlay`, `clockHands`, `thread` and `rakingLight`) into [registry].
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
    ..register(const RakingLightType());
}
