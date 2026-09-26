// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuNewGame => 'New Game';

  @override
  String get menuSettings => 'Settings';

  @override
  String get navLeft => 'Turn left';

  @override
  String get navRight => 'Turn right';

  @override
  String get navBack => 'Step back';

  @override
  String get contentLoadError => 'The game content could not be loaded.';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get examineItem => 'Examine';

  @override
  String get closeExamine => 'Close';

  @override
  String get inventoryLabel => 'Inventory';

  @override
  String get closePuzzle => 'Close';

  @override
  String get dialNext => 'Next symbol';

  @override
  String get dialPrevious => 'Previous symbol';

  @override
  String get newGameConfirmTitle => 'Start a new game?';

  @override
  String get newGameConfirmBody =>
      'Your current progress in this episode will be lost.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionStartOver => 'Start over';

  @override
  String get saveCorruptedTitle => 'Saved game can\'t be read';

  @override
  String get saveCorruptedBody =>
      'Your saved progress is damaged and can\'t be continued. You can start a new game.';

  @override
  String get settingsMusicVolume => 'Music volume';

  @override
  String get settingsSfxVolume => 'Sound effects volume';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageDevice => 'Device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get resetConfirmTitle => 'Reset all progress?';

  @override
  String get resetConfirmBody =>
      'All saved progress will be deleted. Your settings are kept.';

  @override
  String get actionReset => 'Reset';

  @override
  String get progressResetDone => 'Progress has been reset.';

  @override
  String get episodeComplete => 'The tale is distilled';

  @override
  String get hintButton => 'Hint';

  @override
  String get hintTitle => 'Hints';

  @override
  String get hintRevealNext => 'Show a hint';

  @override
  String get hintNoneAvailable => 'No hints right now.';

  @override
  String get hintAllShown => 'That\'s every hint for now.';

  @override
  String get actionClose => 'Close';

  @override
  String get menuTagline =>
      'Every jar keeps a tale that must not be forgotten.';

  @override
  String get shelfTitle => 'The shelf';

  @override
  String get shelfHint => 'Choose a jar to open its tale.';

  @override
  String get jarSealed => 'Still sealed';

  @override
  String get jarDistilled => 'Distilled';

  @override
  String get jarUnfinished => 'You left this tale unfinished.';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionOpenJar => 'Open the jar';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => 'Not yet';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Distil $count more tales to open this jar.',
      one: 'Distil one more tale to open this jar.',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling =>
      'The candle for the next hint is still catching. Keep looking a little longer.';
}
