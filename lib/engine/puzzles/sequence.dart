import '../json/json_reader.dart';
import '../model/content_ref.dart';
import '../model/normalized_rect.dart';
import 'puzzle_type.dart';

/// `sequence`: tap elements in the right order. A wrong tap resets progress.
///
/// ```json
/// "config": {
///   "elements": [
///     { "id": "pane_1", "rect": [0.1, 0.1, 0.2, 0.3], "image": "images/..." }
///   ],
///   "solution": ["pane_3", "pane_1", "pane_4", "pane_2"]
/// }
/// ```
/// Rects are normalized to the puzzle board. `image` and `labelKey` (text
/// shown under the element) are optional. The same element may appear more
/// than once in `solution`.
final class SequenceType implements PuzzleType {
  const SequenceType();

  static const typeId = 'sequence';

  @override
  String get id => typeId;

  @override
  SequenceConfig parseConfig(JsonReader json) {
    json.allowOnly({'elements', 'solution'});
    final elements = [
      for (final e in json.objects('elements')) SequenceElement._fromJson(e),
    ];
    if (elements.isEmpty) json.fail('need at least one element', 'elements');
    final ids = <String>{};
    for (final e in elements) {
      if (!ids.add(e.id)) json.fail('duplicate id "${e.id}"', 'elements');
    }
    final solution = json.strings('solution');
    if (solution.isEmpty) json.fail('must not be empty', 'solution');
    for (final (i, id) in solution.indexed) {
      if (!ids.contains(id)) json.fail('unknown element "$id"', 'solution[$i]');
    }
    return SequenceConfig(elements: elements, solution: solution);
  }
}

final class SequenceElement {
  const SequenceElement({
    required this.id,
    required this.rect,
    this.image,
    this.labelKey,
  });

  factory SequenceElement._fromJson(JsonReader json) {
    json.allowOnly({'id', 'rect', 'image', 'labelKey'});
    return SequenceElement(
      id: json.string('id'),
      rect: NormalizedRect.fromJson(json, 'rect'),
      image: json.optionalString('image'),
      labelKey: json.optionalString('labelKey'),
    );
  }

  final String id;
  final NormalizedRect rect;
  final String? image;
  final String? labelKey;
}

final class SequenceConfig implements PuzzleConfig {
  SequenceConfig({
    required List<SequenceElement> elements,
    required List<String> solution,
  }) : elements = List.unmodifiable(elements),
       solution = List.unmodifiable(solution);

  final List<SequenceElement> elements;
  final List<String> solution;

  SequenceState start() => SequenceState(this, 0);

  @override
  Iterable<ContentRef> get references => [
    for (final e in elements) ...[
      if (e.image case final image?) ContentRef.image(image),
      if (e.labelKey case final key?) ContentRef.text(key),
    ],
  ];
}

enum SequenceOutcome {
  /// Correct so far.
  progress,

  /// Wrong element; progress was reset.
  mistake,

  /// The whole sequence is complete.
  solved,
}

final class SequenceState {
  const SequenceState(this.config, this.progress);

  final SequenceConfig config;

  /// How many elements of the solution have been tapped correctly.
  final int progress;

  bool get isSolved => progress == config.solution.length;

  (SequenceState, SequenceOutcome) tap(String elementId) {
    if (isSolved) return (this, SequenceOutcome.solved);
    if (config.solution[progress] != elementId) {
      // Restart, counting this tap if it is the first step.
      final restart = config.solution.first == elementId ? 1 : 0;
      return (SequenceState(config, restart), SequenceOutcome.mistake);
    }
    final next = SequenceState(config, progress + 1);
    return (
      next,
      next.isSolved ? SequenceOutcome.solved : SequenceOutcome.progress,
    );
  }
}
