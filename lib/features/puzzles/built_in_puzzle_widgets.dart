import '../../engine/engine.dart';
import 'code_lock/code_lock_view.dart';
import 'puzzle_view.dart';
import 'rotary_align/rotary_align_view.dart';
import 'sequence/sequence_view.dart';
import 'slot_placement/slot_placement_view.dart';

/// Widgets for the v1 puzzle types (PRD FR-04).
PuzzleWidgetRegistry builtInPuzzleWidgets() => PuzzleWidgetRegistry()
  ..register(CodeLockType.typeId, CodeLockView.new)
  ..register(SequenceType.typeId, SequenceView.new)
  ..register(RotaryAlignType.typeId, RotaryAlignView.new)
  ..register(SlotPlacementType.typeId, SlotPlacementView.new);
