/// Word markup in content text: `[[word_id]]` marks a word the player can
/// note down; it reads as the word's label in the current language.
///
/// ```text
/// "Found in [[bucks_row]], [[aug31]]."
/// ```
library;

sealed class MarkupPart {
  const MarkupPart();
}

final class PlainPart extends MarkupPart {
  const PlainPart(this.text);

  final String text;
}

final class WordPart extends MarkupPart {
  const WordPart(this.wordId);

  final String wordId;
}

final _word = RegExp(r'\[\[([a-z0-9_]+)\]\]');

/// Splits [text] into plain runs and marked words, in order.
List<MarkupPart> parseMarkup(String text) {
  final parts = <MarkupPart>[];
  var at = 0;
  for (final match in _word.allMatches(text)) {
    if (match.start > at) parts.add(PlainPart(text.substring(at, match.start)));
    parts.add(WordPart(match.group(1)!));
    at = match.end;
  }
  if (at < text.length) parts.add(PlainPart(text.substring(at)));
  return parts;
}

/// Word ids marked in [text].
Set<String> markedWords(String text) => {
  for (final m in _word.allMatches(text)) m.group(1)!,
};

/// [text] with every mark replaced by [label] of its word id.
String plainText(String text, String Function(String wordId) label) =>
    text.replaceAllMapped(_word, (m) => label(m.group(1)!));
