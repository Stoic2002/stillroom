import 'code_lock.dart';
import 'deduction.dart';
import 'puzzle_type.dart';
import 'reveal.dart';
import 'rotary_align.dart';
import 'sequence.dart';
import 'slot_placement.dart';

/// Registers the built-in puzzle types (PRD FR-04, plus `deduction` and
/// `reveal`) into [registry].
void registerBuiltInPuzzleTypes(PuzzleTypeRegistry registry) {
  registry
    ..register(const CodeLockType())
    ..register(const SequenceType())
    ..register(const RotaryAlignType())
    ..register(const SlotPlacementType())
    ..register(const DeductionType())
    ..register(const RevealType());
}
