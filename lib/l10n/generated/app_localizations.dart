import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// Game title shown in the task switcher and main menu.
  ///
  /// In en, this message translates to:
  /// **'Stillroom'**
  String get appTitle;

  /// Main menu button: resume saved game.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get menuContinue;

  /// Main menu button: start a new game.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get menuNewGame;

  /// Main menu button: open settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// Accessibility label of the left scene arrow.
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get navLeft;

  /// Accessibility label of the right scene arrow.
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get navRight;

  /// Accessibility label of the back / zoom-out arrow.
  ///
  /// In en, this message translates to:
  /// **'Step back'**
  String get navBack;

  /// Shown when episode content fails to load.
  ///
  /// In en, this message translates to:
  /// **'The game content could not be loaded.'**
  String get contentLoadError;

  /// Button returning to the main menu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// Button that opens the close-up view of the selected inventory item.
  ///
  /// In en, this message translates to:
  /// **'Examine'**
  String get examineItem;

  /// Button that closes the item close-up view.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeExamine;

  /// Accessibility label of the inventory bar.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryLabel;

  /// Button that closes a puzzle screen without solving it.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closePuzzle;

  /// Accessibility label: turn a code-lock dial forward.
  ///
  /// In en, this message translates to:
  /// **'Next symbol'**
  String get dialNext;

  /// Accessibility label: turn a code-lock dial back.
  ///
  /// In en, this message translates to:
  /// **'Previous symbol'**
  String get dialPrevious;

  /// Confirm dialog title before overwriting progress.
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get newGameConfirmTitle;

  /// Confirm dialog body before a new game.
  ///
  /// In en, this message translates to:
  /// **'Your current progress in this episode will be lost.'**
  String get newGameConfirmBody;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Confirms starting a new game.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get actionStartOver;

  /// Dialog title when the save is damaged.
  ///
  /// In en, this message translates to:
  /// **'Saved game can\'t be read'**
  String get saveCorruptedTitle;

  /// Dialog body when the save is damaged.
  ///
  /// In en, this message translates to:
  /// **'Your saved progress is damaged and can\'t be continued. You can start a new game.'**
  String get saveCorruptedBody;

  /// Settings slider label.
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get settingsMusicVolume;

  /// Settings slider label.
  ///
  /// In en, this message translates to:
  /// **'Sound effects volume'**
  String get settingsSfxVolume;

  /// Settings section label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option that follows the device setting.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageDevice;

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// Settings switch label.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// Settings button that deletes all saved progress.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get settingsResetProgress;

  /// Confirm dialog title for resetting progress.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get resetConfirmTitle;

  /// Confirm dialog body for resetting progress.
  ///
  /// In en, this message translates to:
  /// **'All saved progress will be deleted. Your settings are kept.'**
  String get resetConfirmBody;

  /// Confirms resetting progress.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// Snackbar after resetting progress.
  ///
  /// In en, this message translates to:
  /// **'Progress has been reset.'**
  String get progressResetDone;

  /// Title of the end-of-episode screen.
  ///
  /// In en, this message translates to:
  /// **'The tale is distilled'**
  String get episodeComplete;

  /// Tooltip of the hint button.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hintButton;

  /// Title of the hint dialog.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintTitle;

  /// Button that reveals the next hint.
  ///
  /// In en, this message translates to:
  /// **'Show a hint'**
  String get hintRevealNext;

  /// Hint dialog when nothing is on offer.
  ///
  /// In en, this message translates to:
  /// **'No hints right now.'**
  String get hintNoneAvailable;

  /// Hint dialog when all hints are revealed.
  ///
  /// In en, this message translates to:
  /// **'That\'s every hint for now.'**
  String get hintAllShown;

  /// Generic close button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Tagline under the title on the main menu.
  ///
  /// In en, this message translates to:
  /// **'Every jar keeps a tale that must not be forgotten.'**
  String get menuTagline;

  /// Title of the episode picker (a shelf of jars).
  ///
  /// In en, this message translates to:
  /// **'The shelf'**
  String get shelfTitle;

  /// Instruction on the episode picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a jar to open its tale.'**
  String get shelfHint;

  /// Label on a jar whose episode is not available yet.
  ///
  /// In en, this message translates to:
  /// **'Still sealed'**
  String get jarSealed;

  /// Badge on a jar whose episode is completed.
  ///
  /// In en, this message translates to:
  /// **'Distilled'**
  String get jarDistilled;

  /// Dialog body when opening a jar with saved progress.
  ///
  /// In en, this message translates to:
  /// **'You left this tale unfinished.'**
  String get jarUnfinished;

  /// Resume saved progress.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// Starts an episode from the shelf.
  ///
  /// In en, this message translates to:
  /// **'Open the jar'**
  String get actionOpenJar;

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// Language option, in its own language (Simplified Chinese).
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// Dialog title when a jar on a higher shelf is still locked.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get jarLockedTitle;

  /// How many more tales must be finished before a locked jar opens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Distil one more tale to open this jar.} other{Distil {count} more tales to open this jar.}}'**
  String jarLocked(int count);

  /// Language option, in its own language.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// Hint dialog while the next hint's candle is still burning (hints are paced).
  ///
  /// In en, this message translates to:
  /// **'The candle for the next hint is still catching. Keep looking a little longer.'**
  String get hintKindling;

  /// Heading of the keeper's note in a jar's dialog.
  ///
  /// In en, this message translates to:
  /// **'The keeper\'s note'**
  String get keeperNoteTitle;

  /// Shown when the player finds an episode's secret.
  ///
  /// In en, this message translates to:
  /// **'You found one of the keeper\'s notes.'**
  String get keeperNoteFound;

  /// Toast when the player notes a word from a text.
  ///
  /// In en, this message translates to:
  /// **'Noted: {word}'**
  String wordNoted(String word);

  /// Instruction on the deduction (jar label) screen.
  ///
  /// In en, this message translates to:
  /// **'Write the jar\'s label: tap a blank, then a word you have noted.'**
  String get deductionInstruction;

  /// Button that checks the deduction.
  ///
  /// In en, this message translates to:
  /// **'Distil'**
  String get deductionCheck;

  /// Deduction checked with empty blanks.
  ///
  /// In en, this message translates to:
  /// **'Some blanks are still empty.'**
  String get deductionIncomplete;

  /// Deduction checked with a few wrong blanks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One of these is not right yet.} other{{count} of these are not right yet.}}'**
  String deductionNearMiss(int count);

  /// Deduction checked with many wrong blanks.
  ///
  /// In en, this message translates to:
  /// **'Something here is not right.'**
  String get deductionWrong;

  /// Deduction screen when no words are noted.
  ///
  /// In en, this message translates to:
  /// **'You have not noted any words yet. Tap the underlined words in what you read.'**
  String get deductionNoWords;

  /// Instruction on a wipe-to-reveal puzzle.
  ///
  /// In en, this message translates to:
  /// **'Wipe it with your finger.'**
  String get revealWipe;

  /// Instruction on a rub-to-reveal puzzle.
  ///
  /// In en, this message translates to:
  /// **'Shade it with the pencil: rub with your finger.'**
  String get revealRub;

  /// Shown under a text with underlined words until the player notes a first word.
  ///
  /// In en, this message translates to:
  /// **'Tap an underlined word to note it down.'**
  String get wordTapTip;

  /// Instruction on a crank (winding) puzzle.
  ///
  /// In en, this message translates to:
  /// **'Turn the handle round and round.'**
  String get crankInstruction;

  /// Title of the map of tales (episode picker by place).
  ///
  /// In en, this message translates to:
  /// **'The map of tales'**
  String get mapTitle;

  /// Hint at the bottom of the map.
  ///
  /// In en, this message translates to:
  /// **'Every pin is a tale. Pinch to look closer.'**
  String get mapHint;

  /// Settings switch: show the frame-rate readout.
  ///
  /// In en, this message translates to:
  /// **'Show frame rate (FPS)'**
  String get settingsShowFps;

  /// Tooltip of the button that raises the lens between eras
  ///
  /// In en, this message translates to:
  /// **'Raise the lens'**
  String get lensRaise;

  /// Tooltip of the button that lowers the lens between eras
  ///
  /// In en, this message translates to:
  /// **'Lower the lens'**
  String get lensLower;

  /// How to play the overlay puzzle: drag see-through sheets, tap to turn
  ///
  /// In en, this message translates to:
  /// **'Drag the pieces. Tap one to turn it.'**
  String get overlayInstruction;

  /// How to play a jar label that is written wrong in places
  ///
  /// In en, this message translates to:
  /// **'Some of these words are wrong. Tap one, then the word that belongs there. \"Distil\" checks it.'**
  String get deductionCorrectionInstruction;

  /// Heading printed on a telegram-form jar label
  ///
  /// In en, this message translates to:
  /// **'TELEGRAM'**
  String get telegramHeader;

  /// Word between telegram sentences; empty where the language does not use one
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get telegramStop;

  /// How to play the clock-hands puzzle
  ///
  /// In en, this message translates to:
  /// **'Drag the hands round the dial.'**
  String get clockHandsInstruction;

  /// How to play the red-thread map puzzle
  ///
  /// In en, this message translates to:
  /// **'Draw the thread from pin to pin.'**
  String get threadInstruction;

  /// How to play the raking-light puzzle: move a lamp round a surface
  ///
  /// In en, this message translates to:
  /// **'Move the lamp round the tablet, close and low.'**
  String get rakingLightInstruction;

  /// How to play the beam puzzle: tap things while the turning lighthouse beam lights them.
  ///
  /// In en, this message translates to:
  /// **'Watch the beam. Tap what it shows while it is lit.'**
  String get beamSweepInstruction;

  /// Shown when the player taps a target in the beam puzzle while it is dark.
  ///
  /// In en, this message translates to:
  /// **'Too dark there. Wait for the beam.'**
  String get beamSweepMiss;

  /// How to play the swell puzzle: step down to the sea between the waves.
  ///
  /// In en, this message translates to:
  /// **'Tap to go down a step. Watch the sea, and listen.'**
  String get swellInstruction;

  /// Shown when a wave catches the player in the swell puzzle and sends them back to the top.
  ///
  /// In en, this message translates to:
  /// **'The sea drives you back up the steps.'**
  String get swellCaught;

  /// How to play the roster puzzle: tap cells to change them.
  ///
  /// In en, this message translates to:
  /// **'Tap a box to change it.'**
  String get rosterInstruction;

  /// Shown when the roster board is full but some rows are wrong.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One row does not fit what you found.} other{{count} rows do not fit what you found.}}'**
  String rosterWrong(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'id',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
