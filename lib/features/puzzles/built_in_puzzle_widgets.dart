import '../../engine/engine.dart';
import 'code_lock/code_lock_view.dart';
import 'crank/crank_view.dart';
import 'deduction/deduction_view.dart';
import 'overlay/overlay_view.dart';
import 'puzzle_view.dart';
import 'reveal/reveal_view.dart';
import 'rotary_align/rotary_align_view.dart';
import 'sequence/sequence_view.dart';
import 'slot_placement/slot_placement_view.dart';

/// Widgets for the built-in puzzle types (PRD FR-04, plus `deduction`,
/// `reveal`, `crank` and `overlay`).
PuzzleWidgetRegistry builtInPuzzleWidgets() => PuzzleWidgetRegistry()
  ..register(CodeLockType.typeId, CodeLockView.new)
  ..register(SequenceType.typeId, SequenceView.new)
  ..register(RotaryAlignType.typeId, RotaryAlignView.new)
  ..register(SlotPlacementType.typeId, SlotPlacementView.new)
  ..register(DeductionType.typeId, DeductionView.new)
  ..register(RevealType.typeId, RevealView.new)
  ..register(CrankType.typeId, CrankView.new)
  ..register(OverlayType.typeId, OverlayView.new);
