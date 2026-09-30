import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// The loose sheets of a manuscript gathering, laid open page by page in
/// the order they now nest. Each page shows its first word at the head
/// and the catchword at its foot; arcs beneath join the two leaves of each
/// sheet. Tap a sheet, then another, to swap where they nest; turn a sheet
/// over to swap its leaves. The page last tapped is read in full below.
class QuireView extends StatefulWidget {
  const QuireView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<QuireView> createState() => _QuireViewState();
}

class _QuireViewState extends State<QuireView>
    with SolvesAfterPause<QuireView> {
  late final _config = widget.context.puzzle.config as QuireConfig;
  late QuireState _state = _config.start();

  /// The sheet picked to move or turn.
  int? _picked;

  /// The place whose page is read in full below.
  int _reading = 0;

  void _tap(int p) {
    if (isSolved) return;
    final sheet = _state.sheetAt(p);
    final picked = _picked;
    if (picked == null || picked == sheet) {
      setState(() {
        _picked = picked == sheet ? null : sheet;
        _reading = p;
      });
      widget.context.feedback(UiSound.page);
      return;
    }
    _apply(_state.swap(_state.order.indexOf(picked), _state.depthOf(p)));
    setState(() {
      _picked = null;
      _reading = p;
    });
  }

  void _turn() {
    final picked = _picked;
    if (isSolved || picked == null) return;
    _apply(_state.turn(picked));
  }

  void _apply(QuireState next) {
    final before = _state.links;
    setState(() => _state = next);
    if (next.isSolved) {
      setState(() => _picked = null);
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(
        next.links > before ? UiSound.catchword : UiSound.place,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final texts = [
      for (final key in _config.leaves) widget.context.text(context, key),
    ];
    final places = _state.length;
    final picked = _picked;
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 6),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                for (var p = 0; p < places; p++) ...[
                  Expanded(
                    child: GestureDetector(
                      key: ValueKey('quire_page_$p'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _tap(p),
                      child: _Page(
                        head: catchword(texts[_state.leafAt(p)]),
                        foot: _state.leafAt(p) + 1 < places
                            ? catchword(texts[_state.leafAt(p) + 1])
                            : null,
                        picked: _state.sheetAt(p) == picked,
                        reading: p == _reading,
                      ),
                    ),
                  ),
                  if (p < places - 1)
                    SizedBox(
                      width: 12,
                      child: CustomPaint(
                        painter: _LinkPainter(linked: _state.linked(p)),
                      ),
                    ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: CustomPaint(
              size: Size.infinite,
              painter: _FoldPainter(
                places: places,
                gap: 12,
                picked: picked == null ? null : _state.order.indexOf(picked),
              ),
            ),
          ),
          Row(
            children: [
              FilledButton.tonal(
                key: const ValueKey('quire_turn'),
                onPressed: picked == null || isSolved ? null : _turn,
                child: Text(l10n.quireTurn),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.quireLinks(_state.links, places - 1),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontFamily: AppTheme.smallCaps,
                    fontSize: 14,
                    color: StillroomPalette.paperShade,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xE6E3D3B0),
            child: Text(
              texts[_state.leafAt(_reading)],
              key: const ValueKey('quire_reading'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTheme.serif,
                fontSize: 14,
                height: 1.25,
                color: StillroomPalette.inkOnPaper,
              ),
            ),
          ),
          const SizedBox(height: 4),
          PuzzleLabel(
            picked == null ? l10n.quireInstruction : l10n.quirePicked,
          ),
        ],
      ),
    );
  }
}

/// One page: burnished paper, the first word at its head, faint lines of
/// script, and the catchword at its foot (the last page ends in a small
/// triangle of dots).
class _Page extends StatelessWidget {
  const _Page({
    required this.head,
    required this.foot,
    required this.picked,
    required this.reading,
  });

  final String head;
  final String? foot;
  final bool picked;
  final bool reading;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF2E2016);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE6D6B0),
        border: Border.all(
          color: picked ? StillroomPalette.gaslight : const Color(0xFF8A7650),
          width: picked ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: reading ? 14 : 6,
            color: reading
                ? StillroomPalette.gaslight.withValues(alpha: 0.5)
                : const Color(0x99000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                head,
                style: const TextStyle(
                  fontFamily: AppTheme.serif,
                  fontSize: 16,
                  color: ink,
                ),
              ),
            ),
            const Expanded(
              child: CustomPaint(size: Size.infinite, painter: _ScriptLines()),
            ),
            SizedBox(
              height: 20,
              child: foot == null
                  ? const CustomPaint(
                      size: Size.infinite,
                      painter: _FinisPainter(),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          foot!,
                          style: const TextStyle(
                            fontFamily: AppTheme.serif,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: Color(0xFF7A2A18),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Faint ruled lines of script in the body of a page.
class _ScriptLines extends CustomPainter {
  const _ScriptLines();

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0x552E2016)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const step = 9.0;
    for (var y = step / 2, i = 0; y < size.height; y += step, i++) {
      final short = (i * 37 % 5) * 0.06;
      canvas.drawLine(
        Offset(size.width * (0.06 + short), y),
        Offset(size.width * 0.94, y),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(_ScriptLines old) => false;
}

/// The end of the book: a small triangle of dots, narrowing to a point.
class _FinisPainter extends CustomPainter {
  const _FinisPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = const Color(0xFF7A2A18);
    final c = Offset(size.width / 2, size.height * 0.3);
    for (final (row, count) in [(0, 3), (1, 2), (2, 1)]) {
      for (var i = 0; i < count; i++) {
        canvas.drawCircle(
          c + Offset((i - (count - 1) / 2) * 5, row * 4.5),
          1.4,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FinisPainter old) => false;
}

/// The gap between two pages: a thread of gold when the catchword meets
/// the next page, a faint break when it does not.
class _LinkPainter extends CustomPainter {
  const _LinkPainter({required this.linked});

  final bool linked;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - 12;
    if (linked) {
      canvas
        ..drawLine(
          Offset(-2, y),
          Offset(size.width + 2, y),
          Paint()
            ..color = StillroomPalette.gaslight
            ..strokeWidth = 2.5,
        )
        ..drawCircle(
          Offset(size.width / 2, y),
          3.5,
          Paint()..color = StillroomPalette.gaslight,
        );
    } else {
      canvas.drawCircle(
        Offset(size.width / 2, y),
        2,
        Paint()..color = const Color(0x66D8C9A8),
      );
    }
  }

  @override
  bool shouldRepaint(_LinkPainter old) => old.linked != linked;
}

/// The folds beneath the pages: each sheet an arc joining its two leaves,
/// the outermost sheet the widest and deepest.
class _FoldPainter extends CustomPainter {
  const _FoldPainter({
    required this.places,
    required this.gap,
    required this.picked,
  });

  final int places;

  /// The gap between two pages.
  final double gap;

  /// The depth of the picked sheet, if any.
  final int? picked;

  @override
  void paint(Canvas canvas, Size size) {
    final page = (size.width - gap * (places - 1)) / places;
    double centre(int p) => p * (page + gap) + page / 2;
    final sheets = places ~/ 2;
    for (var k = 0; k < sheets; k++) {
      final left = centre(k);
      final right = centre(places - 1 - k);
      final depth = size.height * (0.9 - k * 0.7 / sheets);
      final chosen = k == picked;
      canvas.drawPath(
        Path()
          ..moveTo(left, 0)
          ..cubicTo(left, depth, right, depth, right, 0),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = chosen ? 2.5 : 1.2
          ..color = chosen
              ? StillroomPalette.gaslight
              : const Color(0x88D8C9A8),
      );
    }
  }

  @override
  bool shouldRepaint(_FoldPainter old) =>
      old.picked != picked || old.places != places;
}
