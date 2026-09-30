import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_strings.dart';
import '../../content/episode_catalog.dart';
import '../../content/world_map.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/stillroom_palette.dart';
import '../../core/widgets/atmosphere.dart';
import '../../core/widgets/keeper_star.dart';
import '../../debug/tester_flags.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/content_providers.dart';
import '../../state/save_repository.dart';
import 'jar_actions.dart';
import 'widgets/menu_music.dart';

/// The map of tales: an old chart of the world with a brass pin where each
/// tale happened (`place` in `episodes.json`). Tapping a pin picks its jar,
/// as on the shelf; the shelf, with its difficulty tiers, is a button away.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  /// Width : height of the chart (equirectangular, 360° by 142°).
  static const aspect = 360 / (WorldMap.north - WorldMap.south);

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _transform = TransformationController();
  Size? _fittedTo;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  static Offset _project(MapPlace place, Size chart) => Offset(
    (place.lon + 180) / 360 * chart.width,
    (WorldMap.north - place.lat) /
        (WorldMap.north - WorldMap.south) *
        chart.height,
  );

  /// Starts zoomed on the pins, with room around them.
  void _fit(Size viewport, Size chart, List<Offset> pins) {
    if (_fittedTo == viewport || pins.isEmpty) return;
    _fittedTo = viewport;
    var box = Rect.fromPoints(pins.first, pins.first);
    for (final p in pins) {
      box = box.expandToInclude(Rect.fromPoints(p, p));
    }
    // At least a quarter of the world across, and a margin for the labels.
    final minWidth = chart.width / 4;
    box = Rect.fromCenter(
      center: box.center,
      width: math.max(box.width, minWidth) + 240,
      height: math.max(box.height, minWidth / MapScreen.aspect) + 200,
    );
    final minScale = math.max(
      viewport.width / chart.width,
      viewport.height / chart.height,
    );
    final scale = math
        .min(viewport.width / box.width, viewport.height / box.height)
        .clamp(minScale, 4.0);
    final dx = (viewport.width / 2 - box.center.dx * scale).clamp(
      viewport.width - chart.width * scale,
      0.0,
    );
    final dy = (viewport.height / 2 - box.center.dy * scale).clamp(
      viewport.height - chart.height * scale,
      0.0,
    );
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final catalog = ref.watch(episodeCatalogProvider).value ?? const [];
    final strings = ref.watch(contentStringsProvider).value ?? const {};
    final map = ref.watch(worldMapProvider).value;
    final save = ref.watch(saveRepositoryProvider);
    final progress = ShelfProgress(catalog, {
      for (final e in catalog)
        if (save.isCompleted(e.id)) e.id,
    }, unlockAll: unlockAllJars);
    String text(String key) => contentText(strings, language, key);

    return MenuMusic(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.mapTitle),
          actions: [
            TextButton.icon(
              key: const ValueKey('open_shelf'),
              icon: const Icon(Icons.shelves),
              label: Text(l10n.shelfTitle),
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.shelf),
            ),
          ],
        ),
        body: Atmosphere(
          vignette: 0.7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = constraints.biggest;
              var chart = Size(
                viewport.height * MapScreen.aspect,
                viewport.height,
              );
              if (chart.width < viewport.width) {
                chart = Size(viewport.width, viewport.width / MapScreen.aspect);
              }
              final pinned = [
                for (final e in catalog)
                  if (e.place case final place? when e.playable)
                    (entry: e, at: _project(place, chart)),
              ];
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _fit(viewport, chart, [for (final p in pinned) p.at]),
              );
              return Stack(
                children: [
                  InteractiveViewer(
                    transformationController: _transform,
                    constrained: false,
                    minScale: math.max(
                      viewport.width / chart.width,
                      viewport.height / chart.height,
                    ),
                    maxScale: 6,
                    child: SizedBox.fromSize(
                      size: chart,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: CustomPaint(painter: _ChartPainter(map)),
                            ),
                          ),
                          for (final (i, (:entry, at: _)) in pinned.indexed)
                            _PositionedPin(
                              key: ValueKey('pin_${entry.id}'),
                              index: i,
                              all: [for (final p in pinned) p.at],
                              transform: _transform,
                              pin: (place) => _Pin(
                                place: place,
                                label: text(entry.titleKey),
                                shelf: entry.shelf,
                                locked: !progress.isUnlocked(entry),
                                distilled: save.isCompleted(entry.id),
                                keeperNote: save.keeperNote(entry.id) != null,
                                onTap: () => pickJar(
                                  context,
                                  ref,
                                  entry,
                                  progress: progress,
                                  text: text,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          l10n.mapHint,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: StillroomPalette.paperShade,
                            shadows: [Shadow(blurRadius: 6)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Places a pin's point at [at], and keeps it the same size on screen
/// however far the chart is zoomed.
class _PositionedPin extends StatelessWidget {
  const _PositionedPin({
    required this.index,
    required this.all,
    required this.transform,
    required this.pin,
    super.key,
  });

  /// This pin's place in [all].
  final int index;

  /// Every pin's point, so labels can dodge each other.
  final List<Offset> all;

  Offset get at => all[index];
  final TransformationController transform;
  final Widget Function(_LabelPlace place) pin;

  static const width = _Pin.width;
  static const height = _Pin.height;
  static const head = _Pin.head;

  /// About how wide a pin's label is on screen, for dodging.
  static const labelWidth = 124.0;

  /// About how tall a pin's label is on screen.
  static const labelHeight = 24.0;

  /// Where pin [i]'s label goes at [scale]. Pins are placed in list order.
  /// A label goes below its head, or above, where it covers neither a
  /// label already placed nor another pin; failing that, where it covers
  /// no label; failing that it is hidden until the chart is zoomed in (the
  /// pin still opens its jar). Pins on one spot, a series in one city,
  /// thus take turns.
  static _LabelPlace labelPlaceAt(List<Offset> all, int i, double scale) {
    Rect label(Offset at, _LabelPlace place) {
      final p = at * scale;
      final top = place == _LabelPlace.above
          ? p.dy - head / 2 - labelHeight
          : p.dy + head / 2;
      return Rect.fromLTWH(p.dx - labelWidth / 2, top, labelWidth, labelHeight);
    }

    bool clear(Rect r, Iterable<Rect> others) =>
        others.every((o) => !r.overlaps(o));

    final heads = [
      for (final o in all)
        Rect.fromCenter(center: o * scale, width: head, height: head),
    ];
    final placed = <Rect>[];
    var result = _LabelPlace.below;
    for (var k = 0; k <= i; k++) {
      final otherHeads = [
        for (final (j, h) in heads.indexed)
          if (j != k) h,
      ];
      result = _LabelPlace.hidden;
      for (final strict in [true, false]) {
        for (final place in [_LabelPlace.below, _LabelPlace.above]) {
          final r = label(all[k], place);
          if (clear(r, placed) && (!strict || clear(r, otherHeads))) {
            result = place;
            break;
          }
        }
        if (result != _LabelPlace.hidden) break;
      }
      if (result != _LabelPlace.hidden) placed.add(label(all[k], result));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: transform,
      builder: (context, _) {
        final scale = transform.value.getMaxScaleOnAxis();
        final place = labelPlaceAt(all, index, scale);
        final headY = place == _LabelPlace.above ? height - head / 2 : head / 2;
        final k = 1 / scale;
        return Positioned(
          left: at.dx - width / 2,
          top: at.dy - headY,
          width: width,
          height: height,
          child: Transform(
            origin: Offset(width / 2, headY),
            transform: Matrix4.diagonal3Values(k, k, 1),
            child: pin(place),
          ),
        );
      },
    );
  }
}

/// Where a pin's label goes.
enum _LabelPlace { below, above, hidden }

class _Pin extends StatelessWidget {
  const _Pin({
    required this.place,
    required this.label,
    required this.shelf,
    required this.locked,
    required this.distilled,
    required this.keeperNote,
    required this.onTap,
  });

  static const head = 26.0;
  static const width = 190.0;
  static const height = 60.0;

  /// Where the label sits: below the head, above it, or hidden until the
  /// chart is zoomed in.
  final _LabelPlace place;

  bool get labelAbove => place == _LabelPlace.above;
  static const _numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

  final String label;
  final int shelf;
  final bool locked;
  final bool distilled;
  final bool keeperNote;
  final VoidCallback onTap;

  /// The paper tag with the tale's name (and the keeper's star).
  Widget _tag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    color: StillroomPalette.paper,
    child: Text.rich(
      TextSpan(
        text: label,
        children: [
          if (keeperNote)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: KeeperStar(size: 11, glow: false),
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: AppTheme.serif,
        fontSize: 13,
        height: 1.1,
        color: StillroomPalette.inkOnPaper,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final color = distilled
        ? StillroomPalette.oxbloodBright
        : locked
        ? const Color(0xFF6B6760)
        : StillroomPalette.brass;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        // Only the head and the tag take taps: the empty rest of the box
        // must not cover a neighbouring pin's label.
        behavior: HitTestBehavior.deferToChild,
        onTap: onTap,
        child: Opacity(
          opacity: locked ? 0.7 : 1,
          child: Column(
            mainAxisAlignment: labelAbove
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (labelAbove) ...[_tag(), const SizedBox(height: 4)],
              Container(
                width: head,
                height: head,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: StillroomPalette.inkOnPaper,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (locked ? Colors.black : StillroomPalette.gaslight)
                          .withValues(alpha: 0.5),
                      blurRadius: locked ? 4 : 12,
                    ),
                  ],
                ),
                child: locked
                    ? const Icon(
                        Icons.lock,
                        size: 14,
                        color: StillroomPalette.paper,
                      )
                    : Text(
                        shelf <= _numerals.length
                            ? _numerals[shelf - 1]
                            : '$shelf',
                        style: const TextStyle(
                          fontFamily: AppTheme.smallCaps,
                          fontSize: 12,
                          color: StillroomPalette.inkOnPaper,
                        ),
                      ),
              ),
              if (place == _LabelPlace.below) ...[
                const SizedBox(height: 4),
                _tag(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An old chart: stained parchment, a graticule, inked coasts, a compass.
class _ChartPainter extends CustomPainter {
  _ChartPainter(this.map);

  final WorldMap? map;

  static const _land = Color(0xFFAE9A70);
  static const _parchment = Color(0xFFCDBB94);

  Offset _p(double lon, double lat, Size size) => Offset(
    (lon + 180) / 360 * size.width,
    (WorldMap.north - lat) / (WorldMap.north - WorldMap.south) * size.height,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas
      ..drawRect(rect, Paint()..color = _parchment)
      ..drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            radius: 0.9,
            colors: [
              const Color(0x00000000),
              StillroomPalette.walnut.withValues(alpha: 0.55),
            ],
          ).createShader(rect),
      );
    final random = math.Random(21);
    for (var i = 0; i < 24; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        size.height * (0.02 + random.nextDouble() * 0.08),
        Paint()
          ..color = const Color(0xFF7A5A3A).withValues(alpha: 0.07)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.02),
      );
    }

    // Graticule.
    final grid = Paint()
      ..color = StillroomPalette.inkOnPaper.withValues(alpha: 0.18)
      ..strokeWidth = 0.6;
    for (var lon = -180; lon <= 180; lon += 30) {
      canvas.drawLine(
        _p(lon.toDouble(), WorldMap.north, size),
        _p(lon.toDouble(), WorldMap.south, size),
        grid,
      );
    }
    for (var lat = -40; lat <= 80; lat += 20) {
      canvas.drawLine(
        _p(-180, lat.toDouble(), size),
        _p(180, lat.toDouble(), size),
        grid,
      );
    }
    canvas.drawLine(
      _p(-180, 0, size),
      _p(180, 0, size),
      Paint()
        ..color = StillroomPalette.oxblood.withValues(alpha: 0.4)
        ..strokeWidth = 1,
    );

    // Coasts: a soft shore halo, the land, an inked edge.
    final world = map;
    if (world != null) {
      final land = Path();
      for (final ring in world.rings) {
        if (ring.isEmpty) continue;
        final first = _p(ring.first.lon, ring.first.lat, size);
        land.moveTo(first.dx, first.dy);
        for (final pt in ring.skip(1)) {
          final o = _p(pt.lon, pt.lat, size);
          land.lineTo(o.dx, o.dy);
        }
        land.close();
      }
      for (final (width, alpha) in [(7.0, 0.06), (4.0, 0.1)]) {
        canvas.drawPath(
          land,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeJoin = StrokeJoin.round
            ..color = StillroomPalette.inkOnPaper.withValues(alpha: alpha),
        );
      }
      canvas
        ..drawPath(land, Paint()..color = _land)
        ..drawPath(
          land,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.9
            ..strokeJoin = StrokeJoin.round
            ..color = StillroomPalette.inkOnPaper.withValues(alpha: 0.85),
        );
    }

    _compass(
      canvas,
      Offset(size.width * 0.06, size.height * 0.84),
      size.height * 0.07,
    );
  }

  void _compass(Canvas canvas, Offset c, double r) {
    final ink = Paint()
      ..color = StillroomPalette.inkOnPaper.withValues(alpha: 0.7);
    final light = Paint()..color = _parchment;
    canvas.drawCircle(
      c,
      r * 1.05,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = ink.color,
    );
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = i.isEven ? r : r * 0.55;
      final tip = c + Offset(math.cos(a), math.sin(a)) * len;
      final side =
          Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) *
          r *
          0.12;
      canvas
        ..drawPath(Path()..addPolygon([c + side, tip, c], true), ink)
        ..drawPath(Path()..addPolygon([c - side, tip, c], true), light);
    }
    final painter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          fontFamily: AppTheme.smallCaps,
          fontSize: r * 0.4,
          color: StillroomPalette.inkOnPaper,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, c + Offset(-painter.width / 2, -r * 1.55));
  }

  @override
  bool shouldRepaint(_ChartPainter old) => old.map != map;
}
