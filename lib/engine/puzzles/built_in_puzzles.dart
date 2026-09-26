import 'code_lock.dart';
import 'puzzle_type.dart';
import 'rotary_align.dart';
import 'sequence.dart';
import 'slot_placement.dart';

/// Registers the v1 puzzle types (PRD FR-04) into [registry].
void registerBuiltInPuzzleTypes(PuzzleTypeRegistry registry) {
  registry
    ..register(const CodeLockType())
    ..register(const SequenceType())
    ..register(const RotaryAlignType())
    ..register(const SlotPlacementType());
}
