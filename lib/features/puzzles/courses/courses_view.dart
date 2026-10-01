import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/audio/ui_sound.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../puzzle_view.dart';

/// A breach in a dry-stone wall, seen face on: the course still standing
/// at the bottom, the courses to lay above it, the chevron band on top.
/// Beside it the fallen pile. Tap a block to lay it next in the current
/// course; a block that runs past the gap or ends over a joint below is
/// refused. Once every course is laid, tap the band's slabs until they
/// lean in turn.
class CoursesView extends StatefulWidget {
  const CoursesView(this.context, {super.key});

  final PuzzleViewContext context;

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

enum _Note { none, tooLong, joint }

class _CoursesViewState extends State<CoursesView>
    with SolvesAfterPause<CoursesView> {
  late final _config = widget.context.puzzle.config as CoursesConfig;
  late CoursesState _state = _config.start();
  _Note _note = _Note.none;

  void _lay(int block) {
    if (isSolved) return;
    final judged = _state.judge(block);
    if (judged == CoursesLay.none) return;
    final wasDone = _state.coursesDone;
    setState(() {
      _state = _state.lay(block);
      _note = switch (judged) {
        CoursesLay.tooLong => _Note.tooLong,
        CoursesLay.joint => _Note.joint,
        CoursesLay.laid || CoursesLay.none => _Note.none,
      };
    });
    widget.context.feedback(
      judged == CoursesLay.laid
          ? (!wasDone && _state.coursesDone ? UiSound.note : UiSound.blockLay)
          : UiSound.mistake,
    );
  }

  void _takeBack() {
    if (isSolved || _state.laid.isEmpty) return;
    setState(() {
      _state = _state.takeBack();
      _note = _Note.none;
    });
    widget.context.feedback(UiSound.lift);
  }

  void _tilt(int slab) {
    if (isSolved || !_state.coursesDone) return;
    setState(() => _state = _state.tilt(slab));
    if (_state.isSolved) {
      widget.context.feedback(UiSound.solved);
      markSolved(widget.context.onSolved);
    } else {
      widget.context.feedback(UiSound.slabTilt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = switch (_note) {
      _Note.tooLong => l10n.coursesTooLong,
      _Note.joint => l10n.coursesJoint,
      _Note.none when _state.coursesDone => l10n.coursesBand,
      _Note.none => l10n.coursesInstruction,
    };
    final total = _config.blocks.fold(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 10, 28, 6),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final size = box.biggest;
                      return GestureDetector(
                        key: const ValueKey('courses_wall'),
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (d) {
                          final slab = _WallPainter.slabAt(
                            d.localPosition,
                            size,
                            _config,
                          );
                          if (slab != null) _tilt(slab);
                        },
                        child: CustomPaint(
                          size: size,
                          painter: _WallPainter(_config, _state),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 128,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _state.coursesDone
                            ? '✓'
                            : l10n.coursesCourse(
                                _state.current + 1,
                                _config.courses,
                              ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.smallCaps,
                          fontSize: 15,
                          color: StillroomPalette.paperShade,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        key: const ValueKey('courses_take_back'),
                        onPressed: _state.laid.isEmpty || isSolved
                            ? null
                            : _takeBack,
                        style: TextButton.styleFrom(
                          foregroundColor: StillroomPalette.gaslight,
                        ),
                        icon: const Icon(Icons.undo, size: 18),
                        label: Text(l10n.coursesTakeBack),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // The fallen pile, in two rows under the wall.
          LayoutBuilder(
            builder: (context, box) {
              const gap = 8.0;
              final unit = math.min(
                _WallPainter.unitCap,
                (box.maxWidth * 2 - gap * (_config.blocks.length + 2)) /
                    total *
                    0.92,
              );
              return Wrap(
                spacing: gap,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final (i, length) in _config.blocks.indexed)
                    Opacity(
                      opacity: _state.isUsed(i) ? 0.15 : 1,
                      child: GestureDetector(
                        key: ValueKey('courses_block_$i'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _lay(i),
                        child: SizedBox(
                          width: length * unit,
                          height: minTapSizeDp,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: CustomPaint(painter: _BlockPainter(seed: i)),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          PuzzleLabel(status),
        ],
      ),
    );
  }
}

/// The wall in the breach: the standing course, the laid courses, the
/// course being laid marked out, and the chevron band.
class _WallPainter extends CustomPainter {
  const _WallPainter(this.config, this.state);

  final CoursesConfig config;
  final CoursesState state;

  /// The largest a block unit is drawn.
  static const unitCap = 40.0;

  /// Rows: the band, the courses to lay, the course standing.
  static int rows(CoursesConfig c) => c.courses + 2;

  static (double unit, Offset origin) _frame(Size size, CoursesConfig c) {
    final unit = math.min(
      math.min(size.width / c.width, size.height / (rows(c) * 1.1)),
      unitCap * 1.6,
    );
    final w = unit * c.width;
    final h = unit * 1.1 * rows(c);
    return (unit, Offset((size.width - w) / 2, (size.height - h) / 2));
  }

  /// The chevron slab at [p], if the band is there.
  static int? slabAt(Offset p, Size size, CoursesConfig c) {
    final (unit, o) = _frame(size, c);
    final row = unit * 1.1;
    if (p.dy < o.dy || p.dy > o.dy + row) return null;
    final x = p.dx - o.dx;
    final w = unit * c.width;
    if (x < 0 || x >= w) return null;
    return (x / (w / c.chevrons.length)).floor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (unit, o) = _frame(size, config);
    final row = unit * 1.1;
    final w = unit * config.width;
    // The gap in the wall (the wall round it is on the background).
    final gap = Rect.fromLTWH(o.dx, o.dy, w, row * rows(config));
    canvas.drawRect(
      gap.inflate(unit * 0.15),
      Paint()..color = const Color(0x55000000),
    );
    canvas.drawRect(gap, Paint()..color = const Color(0x33100C08));
    // The course still standing, at the bottom.
    _course(canvas, config.base, o.dy + row * (rows(config) - 1), o.dx, unit);

    // The courses laid, from the bottom up.
    for (var c = 0; c < config.courses; c++) {
      final y = o.dy + row * (rows(config) - 2 - c);
      if (c == state.current && !state.coursesDone) {
        canvas.drawRect(
          Rect.fromLTWH(o.dx, y, w, row),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = StillroomPalette.gaslight.withValues(alpha: 0.8),
        );
        // Where the joints below are: no block may end there.
        for (final j in state.below) {
          canvas.drawLine(
            Offset(o.dx + j * unit, y + row - 4),
            Offset(o.dx + j * unit, y + row + 4),
            Paint()
              ..strokeWidth = 2
              ..color = const Color(0xCCB03A2A),
          );
        }
      }
      if (c < state.laid.length) {
        var x = o.dx;
        for (final i in state.laid[c]) {
          final length = config.blocks[i];
          _stone(canvas, Rect.fromLTWH(x, y, length * unit, row), i + 20);
          x += length * unit;
        }
      }
    }

    // The chevron band: thin slabs leaning left or right.
    final slabs = config.chevrons.length;
    final slabW = w / slabs;
    final done = state.coursesDone;
    for (var k = 0; k < slabs; k++) {
      final r = Rect.fromLTWH(o.dx + k * slabW, o.dy, slabW, row);
      final lean = state.leans[k] ? 1.0 : -1.0;
      final top = r.center.dx + lean * slabW * 0.32;
      final bottom = r.center.dx - lean * slabW * 0.32;
      final half = slabW * 0.14;
      canvas.drawPath(
        Path()
          ..moveTo(top - half, r.top + 2)
          ..lineTo(top + half, r.top + 2)
          ..lineTo(bottom + half, r.bottom - 2)
          ..lineTo(bottom - half, r.bottom - 2)
          ..close(),
        Paint()
          ..color = done ? const Color(0xFFB4AC9C) : const Color(0x44B4AC9C),
      );
    }
    if (state.isSolved) {
      canvas.drawRect(
        Rect.fromLTWH(o.dx, o.dy, w, row),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = StillroomPalette.gaslight,
      );
    }
  }

  void _course(Canvas canvas, List<int> lengths, double y, double x, double u) {
    var at = x;
    for (final (k, l) in lengths.indexed) {
      _stone(canvas, Rect.fromLTWH(at, y, l * u, u * 1.1), k + 3, dim: true);
      at += l * u;
    }
  }

  static void _stone(Canvas canvas, Rect r, int seed, {bool dim = false}) =>
      _BlockPainter.paintStone(canvas, r.deflate(1.2), seed, dim: dim);

  @override
  bool shouldRepaint(_WallPainter old) => old.state != state;
}

/// One granite block, split face out: grey-buff, a little uneven.
class _BlockPainter extends CustomPainter {
  const _BlockPainter({required this.seed});

  final int seed;

  static void paintStone(Canvas canvas, Rect r, int seed, {bool dim = false}) {
    final random = math.Random(seed);
    final tone = 0.85 + random.nextDouble() * 0.2;
    final base = Color.fromARGB(
      255,
      (172 * tone).round().clamp(0, 255),
      (165 * tone).round().clamp(0, 255),
      (150 * tone).round().clamp(0, 255),
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(2.5)),
        Paint()..color = dim ? Color.lerp(base, Colors.black, 0.35)! : base,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(2.5)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xAA2A241C),
      );
    // Flecks of mica and feldspar.
    for (var i = 0; i < (r.width * r.height / 90).clamp(3, 40); i++) {
      canvas.drawCircle(
        Offset(
          r.left + random.nextDouble() * r.width,
          r.top + random.nextDouble() * r.height,
        ),
        0.8,
        Paint()
          ..color = random.nextBool()
              ? const Color(0x55FFFFFF)
              : const Color(0x55302820),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) =>
      paintStone(canvas, Offset.zero & size, seed + 20);

  @override
  bool shouldRepaint(_BlockPainter old) => old.seed != seed;
}
