import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../engine/engine.dart';
import '../theme/stillroom_palette.dart';

/// Content text with its marked words (`[[id]]`, see `text_markup.dart`)
/// drawn as notable: a dotted brass underline until the player taps and
/// notes the word, then solid and in [MarkedText.notedColor]. The rest is
/// plain text.
class MarkedText extends StatefulWidget {
  const MarkedText(
    this.text, {
    required this.labelOf,
    required this.isNoted,
    this.onWord,
    this.style,
    this.markColor = StillroomPalette.brass,
    this.notedColor = StillroomPalette.oxbloodBright,
    super.key,
  });

  /// Raw content text, markup included.
  final String text;

  /// How word [id] reads in the current language.
  final String Function(String id) labelOf;
  final bool Function(String id) isNoted;

  /// Called when the player taps a marked word.
  final void Function(String id)? onWord;
  final TextStyle? style;

  /// Underline of a word not noted yet.
  final Color markColor;

  /// Color of a noted word and its underline.
  final Color notedColor;

  @override
  State<MarkedText> createState() => _MarkedTextState();
}

class _MarkedTextState extends State<MarkedText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final base = widget.style ?? DefaultTextStyle.of(context).style;
    final spans = <InlineSpan>[];
    for (final part in parseMarkup(widget.text)) {
      switch (part) {
        case PlainPart(:final text):
          spans.add(TextSpan(text: text));
        case WordPart(:final wordId):
          final noted = widget.isNoted(wordId);
          final onWord = widget.onWord;
          final recognizer = onWord == null
              ? null
              : (TapGestureRecognizer()..onTap = () => onWord(wordId));
          if (recognizer != null) _recognizers.add(recognizer);
          spans.add(
            TextSpan(
              text: widget.labelOf(wordId),
              recognizer: recognizer,
              style: TextStyle(
                color: noted
                    ? widget.notedColor
                    : Color.lerp(base.color, widget.markColor, 0.45),
                decoration: TextDecoration.underline,
                decorationStyle: noted
                    ? TextDecorationStyle.solid
                    : TextDecorationStyle.dotted,
                decorationColor: noted ? widget.notedColor : widget.markColor,
                decorationThickness: 2.5,
              ),
            ),
          );
      }
    }
    return Text.rich(TextSpan(style: base, children: spans));
  }
}
