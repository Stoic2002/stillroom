import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/stillroom_palette.dart';
import '../../../core/widgets/keeper_star.dart';
import '../../../engine/engine.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../state/game_session.dart';

/// Brief notes at the top of the game screen: a word the player noted down,
/// or the keeper's note found. Never takes taps.
class GameToasts extends ConsumerStatefulWidget {
  const GameToasts({required this.episodeId, super.key});

  final String episodeId;

  @override
  ConsumerState<GameToasts> createState() => _GameToastsState();
}

class _GameToastsState extends ConsumerState<GameToasts> {
  String? _message;
  bool _golden = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show(String message, {required bool golden}) {
    _timer?.cancel();
    setState(() {
      _message = message;
      _golden = golden;
    });
    _timer = Timer(Duration(milliseconds: golden ? 3200 : 1600), () {
      if (mounted) setState(() => _message = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    ref.listen(gameSessionProvider(widget.episodeId), (previous, next) {
      final session = next.value;
      if (session == null || session.revision == previous?.value?.revision) {
        return;
      }
      for (final event in session.events) {
        switch (event) {
          case SecretFoundEvent():
            _show(l10n.keeperNoteFound, golden: true);
            return;
          case WordNotedEvent(:final wordId):
            _show(
              l10n.wordNoted(session.wordLabel(language, wordId)),
              golden: false,
            );
          default:
            break;
        }
      }
    });

    final message = _message;
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: message == null
                  ? const SizedBox.shrink()
                  : DecoratedBox(
                      key: ValueKey(message),
                      decoration: BoxDecoration(
                        color: StillroomPalette.soot.withValues(alpha: 0.92),
                        border: Border.all(
                          color: _golden
                              ? StillroomPalette.gaslight
                              : StillroomPalette.brass,
                          width: _golden ? 1.5 : 0.8,
                        ),
                        boxShadow: _golden
                            ? const [
                                BoxShadow(
                                  color: Color(0x66E0A84A),
                                  blurRadius: 16,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_golden) ...[
                              const KeeperStar(),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              message,
                              style: TextStyle(
                                fontFamily: AppTheme.serif,
                                fontSize: 16,
                                color: _golden
                                    ? StillroomPalette.gaslight
                                    : StillroomPalette.paper,
                              ),
                            ),
                          ],
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
