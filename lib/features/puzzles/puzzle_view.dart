import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/content_strings.dart';
import '../../core/audio/ui_sound.dart';
import '../../engine/engine.dart';

void _silent(UiSound _) {}

/// What a puzzle widget gets to render one puzzle. Answer checking lives in
/// the engine's puzzle state classes; the widget shows that state, forwards
/// taps, and calls [onSolved] once the state reports solved.
final class PuzzleViewContext {
  const PuzzleViewContext({
    required this.puzzle,
    required this.content,
    required this.game,
    required this.assets,
    required this.onSolved,
    this.strings = const {},
    this.feedback = _silent,
  });

  final Puzzle puzzle;
  final EpisodeContent content;
  final GameState game;

  /// Bundled asset paths, to pick art or a placeholder.
  final Set<String> assets;
  final VoidCallback onSolved;

  /// Content string tables, for labels inside the puzzle.
  final StringTables strings;

  /// Plays an interface sound (and its vibration) for a move.
  final void Function(UiSound sound) feedback;

  /// Content text for [key] in the current language.
  String text(BuildContext context, String key) =>
      contentText(strings, Localizations.localeOf(context).languageCode, key);
}

/// A small caption under a puzzle element (street names, dates, ...).
class PuzzleLabel extends StatelessWidget {
  const PuzzleLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: const TextStyle(
        fontFamily: 'IMFell',
        fontSize: 13,
        height: 1.15,
        color: Color(0xFFD8C9A8),
        shadows: [Shadow(blurRadius: 4)],
      ),
    );
  }
}

typedef PuzzleWidgetBuilder = Widget Function(PuzzleViewContext context);

/// Maps puzzle `type` ids to widgets. A new puzzle type registers its engine
/// [PuzzleType] and a widget here; nothing else changes.
final class PuzzleWidgetRegistry {
  PuzzleWidgetRegistry();

  final Map<String, PuzzleWidgetBuilder> _builders = {};

  void register(String typeId, PuzzleWidgetBuilder builder) {
    if (_builders.containsKey(typeId)) {
      throw ArgumentError.value(typeId, 'typeId', 'widget already registered');
    }
    _builders[typeId] = builder;
  }

  PuzzleWidgetBuilder? operator [](String typeId) => _builders[typeId];
}

/// Shared behavior for puzzle widgets: once solved, input stops and
/// [PuzzleViewContext.onSolved] fires after a short pause, so the player sees
/// the solved state before the screen closes.
mixin SolvesAfterPause<T extends StatefulWidget> on State<T> {
  static const pause = Duration(milliseconds: 700);

  Timer? _timer;

  bool get isSolved => _timer != null;

  void markSolved(VoidCallback onSolved) {
    if (_timer != null) return;
    _timer = Timer(pause, onSolved);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Minimum tap area on the physical screen (NFR-05).
const minTapSizeDp = 44.0;

/// [rect] on a board of [board] size, in pixels.
Rect boardRect(NormalizedRect rect, Size board) => Rect.fromLTWH(
  rect.x * board.width,
  rect.y * board.height,
  rect.width * board.width,
  rect.height * board.height,
);

/// Tap area for [rect]: the rect grown to at least [minTapSizeDp] per side.
Rect boardHitRect(NormalizedRect rect, Size board) => boardRect(
  rect.expandedTo(minTapSizeDp / board.width, minTapSizeDp / board.height),
  board,
);
