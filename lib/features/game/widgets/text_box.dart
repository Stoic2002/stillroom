import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../content/content_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../state/game_session.dart';

/// Shows the first queued text on a scrap of aged paper (PRD FR-07). While
/// it is up, any tap closes it and nothing underneath reacts.
class TextBox extends ConsumerWidget {
  const TextBox({required this.episodeId, super.key});

  final String episodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameSessionProvider(episodeId);
    final session = ref.watch(provider).value;
    final key = session?.currentText;
    if (session == null || key == null) return const SizedBox.shrink();

    final text = contentText(
      session.episode.strings,
      Localizations.localeOf(context).languageCode,
      key,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ref.read(provider.notifier).dismissText,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Transform.rotate(
              angle: -0.008,
              child: ClipPath(
                clipper: const _TornPaper(),
                child: ColoredBox(
                  color: StillroomPalette.paper,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontFamily: AppTheme.serif,
                          fontSize: 18,
                          height: 1.4,
                          color: StillroomPalette.inkOnPaper,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A paper scrap with a ragged bottom edge.
class _TornPaper extends CustomClipper<Path> {
  const _TornPaper();

  @override
  Path getClip(Size size) {
    const tooth = 9.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - tooth);
    var x = size.width;
    var up = true;
    // Deterministic, uneven teeth.
    for (var i = 0; x > 0; i++) {
      final step = 10.0 + (i * 7 % 9);
      x = (x - step).clamp(0, size.width);
      path.lineTo(x, up ? size.height : size.height - tooth);
      up = !up;
    }
    return path
      ..lineTo(0, size.height - tooth)
      ..close();
  }

  @override
  bool shouldReclip(_TornPaper oldClipper) => false;
}
