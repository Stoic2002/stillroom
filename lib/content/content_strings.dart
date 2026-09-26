import 'content_loader.dart';

/// Fallback language when a key is missing in the player's language.
const fallbackContentLocale = 'en';

/// Looks up content text [key] for [languageCode]. Falls back to English, then
/// to the key itself, so missing text is visible instead of blank.
String contentText(StringTables tables, String languageCode, String key) =>
    tables[languageCode]?[key] ?? tables[fallbackContentLocale]?[key] ?? key;
