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

  @override
  String get keeperNoteTitle => 'The keeper\'s note';

  @override
  String get keeperNoteFound => 'You found one of the keeper\'s notes.';

  @override
  String wordNoted(String word) {
    return 'Noted: $word';
  }

  @override
  String get deductionInstruction =>
      'Write the jar\'s label: tap a blank, then a word you have noted.';

  @override
  String get deductionCheck => 'Distil';

  @override
  String get deductionIncomplete => 'Some blanks are still empty.';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of these are not right yet.',
      one: 'One of these is not right yet.',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => 'Something here is not right.';

  @override
  String get deductionNoWords =>
      'You have not noted any words yet. Tap the underlined words in what you read.';

  @override
  String get revealWipe => 'Wipe it with your finger.';

  @override
  String get revealRub => 'Shade it with the pencil: rub with your finger.';

  @override
  String get wordTapTip => 'Tap an underlined word to note it down.';

  @override
  String get crankInstruction => 'Turn the handle round and round.';

  @override
  String get mapTitle => 'The map of tales';

  @override
  String get mapHint => 'Every pin is a tale. Pinch to look closer.';

  @override
  String get settingsShowFps => 'Show frame rate (FPS)';

  @override
  String get lensRaise => 'Raise the lens';

  @override
  String get lensLower => 'Lower the lens';

  @override
  String get overlayInstruction => 'Drag the pieces. Tap one to turn it.';

  @override
  String get deductionCorrectionInstruction =>
      'Some of these words are wrong. Tap one, then the word that belongs there. \"Distil\" checks it.';

  @override
  String get telegramHeader => 'TELEGRAM';

  @override
  String get telegramStop => 'STOP';

  @override
  String get clockHandsInstruction => 'Drag the hands round the dial.';

  @override
  String get threadInstruction => 'Draw the thread from pin to pin.';

  @override
  String get rakingLightInstruction =>
      'Move the lamp round the tablet, close and low.';

  @override
  String get beamSweepInstruction =>
      'Watch the beam. Tap what it shows while it is lit.';

  @override
  String get beamSweepMiss => 'Too dark there. Wait for the beam.';

  @override
  String get swellInstruction =>
      'Tap to go down a step. Watch the sea, and listen.';

  @override
  String get swellCaught => 'The sea drives you back up the steps.';

  @override
  String get rosterInstruction => 'Tap a box to change it.';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rows do not fit what you found.',
      one: 'One row does not fit what you found.',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => 'By order of the King';

  @override
  String get keyringInstruction => 'Take a key off the ring.';

  @override
  String get keyringHand =>
      'Tap the key to turn it over; tap the lock to try it.';

  @override
  String get keyringWrong => 'It will not turn.';

  @override
  String get cipherInstruction =>
      'Tap a number in the letter, then the same number on the worksheet.';

  @override
  String get sourcesInstruction => 'Tap a paper, then the tray it belongs in.';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count papers are in the wrong tray.',
      one: 'One paper is in the wrong tray.',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => 'A rubbing from the bronze';

  @override
  String get pourInstruction => 'Turn the channels, then open the furnaces.';

  @override
  String get pourButton => 'Pour';

  @override
  String get pourSpilt =>
      'The bronze runs out into the sand. The furnaces are closed again.';

  @override
  String get pourShort => 'Nothing spilt, but a cup stayed empty.';

  @override
  String get resonanceInstruction =>
      'Pull the striker back and let it go. Dig or fill the hollow below.';

  @override
  String get resonanceDeeper => 'Deeper';

  @override
  String get resonanceShallower => 'Shallower';

  @override
  String get resonanceWeak => 'Too gentle: the log barely touches the bronze.';

  @override
  String get resonanceShort => 'The ring dies away before the mark.';

  @override
  String get beatInstruction =>
      'Strike the rim. Find where the ring swells deepest, and mark it.';

  @override
  String get beatMark => 'Mark this place';

  @override
  String get beatWrong => 'Not here: somewhere it swells deeper.';

  @override
  String get docketHeader => 'Metropolitan Police';

  @override
  String get docketSubheader => 'Criminal Investigation Department';

  @override
  String get unwatchedInstruction => 'Look away, then look back.';

  @override
  String get unwatchedFind => 'Something on the shelf is new. Find it.';

  @override
  String get unwatchedWrong => 'That one was already there.';

  @override
  String get unwatchedLookAway => 'Look away';

  @override
  String unwatchedProgress(int found, int total) {
    return 'New files found: $found of $total';
  }

  @override
  String get composeInstruction =>
      'Set her name from the case. Type is cut in mirror.';

  @override
  String get composeTakeOut => 'Take out';

  @override
  String get composeWrong => 'The proof reads wrong somewhere.';

  @override
  String get strandInstruction =>
      'Tap a segment to measure it. Find each strand\'s highest reading and mark it.';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings left',
      one: '1 reading left',
      zero: 'No readings left',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => 'Mark as highest';

  @override
  String get strandWrong => 'Not the highest. A neighbour may read higher.';

  @override
  String get strandNewSample => 'New sample';

  @override
  String get strandOut =>
      'No reactor time left on this sample. Take a new one.';

  @override
  String get strandCurveQuestion => 'How does the arsenic run along the hair?';

  @override
  String get strandSteady => 'Steady, over years';

  @override
  String get strandPeak => 'Sharp peaks';

  @override
  String get strandCurveWrong =>
      'Look again at the readings around the highest.';

  @override
  String get scanInstruction =>
      'Drag the probe over the robe. Mark where the needle stands in the red.';

  @override
  String get scanMark => 'Mark here';

  @override
  String get scanWrong => 'The needle hardly moves here.';

  @override
  String get scanFaint =>
      'The needle stirs, but not into the red. Too faint through this cloth?';

  @override
  String get scanAgain => 'Already marked.';

  @override
  String scanFound(String place) {
    return 'Marked: $place';
  }

  @override
  String scanProgress(int found, int total) {
    return 'Places marked: $found of $total';
  }

  @override
  String get vermilionCaption => 'In vermilion';

  @override
  String get quireInstruction =>
      'Tap a sheet, then another, to swap their places in the quire. Turn a sheet over to swap its leaves. Every catchword must meet its page.';

  @override
  String get quireTurn => 'Turn over';

  @override
  String quireLinks(int count, int total) {
    return '$count of $total catchwords meet their pages';
  }

  @override
  String get quirePicked =>
      'Tap another sheet to swap places, or turn this one over.';

  @override
  String get dipInstruction =>
      'Drag the reed down into a tank until it meets the surface, then let go and watch it drip.';

  @override
  String get dipWhat => 'What drips from the reed?';

  @override
  String get dipWrong => 'It does not drip like that.';

  @override
  String dipLevel(int percent) {
    return 'Full to $percent%';
  }

  @override
  String get dipStoresQuestion =>
      'Every tank is named. Were the stores running low, or full?';

  @override
  String get dipLow => 'Running low';

  @override
  String get dipFull => 'Full';

  @override
  String get dipStoresWrong => 'Look again at how high each tank stands.';

  @override
  String get colophonCaption => 'Here the book ends';

  @override
  String get coursesInstruction =>
      'Lay the fallen blocks back, course by course from the left. No block may end over a joint in the course below.';

  @override
  String coursesCourse(int course, int total) {
    return 'Course $course of $total';
  }

  @override
  String get coursesTooLong => 'Too long: it would run past the gap.';

  @override
  String get coursesJoint => 'Joint over joint: the wall would split there.';

  @override
  String get coursesTakeBack => 'Take back';

  @override
  String get coursesBand =>
      'The chevron band: tap a slab to lean it the other way, until they lean in turn.';

  @override
  String get identifyInstruction =>
      'Look at the splinter. Which is true of it?';

  @override
  String identifyWrong(String name) {
    return 'The key ends at: $name';
  }

  @override
  String get identifyBack => 'Back to where the path went wrong.';

  @override
  String get cartoucheCaption => 'A new map of the interior';
}
