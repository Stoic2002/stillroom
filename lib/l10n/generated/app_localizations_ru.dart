// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => 'Продолжить';

  @override
  String get menuNewGame => 'Новая игра';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get navLeft => 'Повернуть налево';

  @override
  String get navRight => 'Повернуть направо';

  @override
  String get navBack => 'Назад';

  @override
  String get contentLoadError => 'Не удалось загрузить содержимое игры.';

  @override
  String get backToMenu => 'В меню';

  @override
  String get examineItem => 'Осмотреть';

  @override
  String get closeExamine => 'Закрыть';

  @override
  String get inventoryLabel => 'Инвентарь';

  @override
  String get closePuzzle => 'Закрыть';

  @override
  String get dialNext => 'Следующий символ';

  @override
  String get dialPrevious => 'Предыдущий символ';

  @override
  String get newGameConfirmTitle => 'Начать новую игру?';

  @override
  String get newGameConfirmBody =>
      'Текущий прогресс в этом эпизоде будет потерян.';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionStartOver => 'Начать заново';

  @override
  String get saveCorruptedTitle => 'Не удаётся прочитать сохранение';

  @override
  String get saveCorruptedBody =>
      'Сохранённый прогресс повреждён, продолжить нельзя. Можно начать новую игру.';

  @override
  String get settingsMusicVolume => 'Громкость музыки';

  @override
  String get settingsSfxVolume => 'Громкость эффектов';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageDevice => 'Язык устройства';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => 'Вибрация';

  @override
  String get settingsResetProgress => 'Сбросить прогресс';

  @override
  String get resetConfirmTitle => 'Сбросить весь прогресс?';

  @override
  String get resetConfirmBody =>
      'Весь сохранённый прогресс будет удалён. Настройки сохранятся.';

  @override
  String get actionReset => 'Сбросить';

  @override
  String get progressResetDone => 'Прогресс сброшен.';

  @override
  String get episodeComplete => 'История дистиллирована';

  @override
  String get hintButton => 'Подсказка';

  @override
  String get hintTitle => 'Подсказки';

  @override
  String get hintRevealNext => 'Показать подсказку';

  @override
  String get hintNoneAvailable => 'Сейчас подсказок нет.';

  @override
  String get hintAllShown => 'Больше подсказок пока нет.';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get menuTagline =>
      'В каждой банке хранится история, которую нельзя забыть.';

  @override
  String get shelfTitle => 'Полка';

  @override
  String get shelfHint => 'Выберите банку, чтобы открыть её историю.';

  @override
  String get jarSealed => 'Ещё запечатана';

  @override
  String get jarDistilled => 'Дистиллирована';

  @override
  String get jarUnfinished => 'Вы не закончили эту историю.';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionOpenJar => 'Открыть банку';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => 'Пока нельзя';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Дистиллируйте ещё $count истории, чтобы открыть эту банку.',
      many: 'Дистиллируйте ещё $count историй, чтобы открыть эту банку.',
      few: 'Дистиллируйте ещё $count истории, чтобы открыть эту банку.',
      one: 'Дистиллируйте ещё $count историю, чтобы открыть эту банку.',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling =>
      'Свеча для следующей подсказки ещё разгорается. Поищите ещё немного.';

  @override
  String get keeperNoteTitle => 'Записка хранителя';

  @override
  String get keeperNoteFound => 'Вы нашли одну из записок хранителя.';

  @override
  String wordNoted(String word) {
    return 'Записано: $word';
  }

  @override
  String get deductionInstruction =>
      'Подпишите банку: коснитесь пропуска, затем записанного слова.';

  @override
  String get deductionCheck => 'Перегнать';

  @override
  String get deductionIncomplete => 'Ещё не все пропуски заполнены.';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пока неверны.',
      few: '$count пока неверны.',
      one: 'Одно пока неверно.',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => 'Что-то здесь не так.';

  @override
  String get deductionNoWords =>
      'Вы ещё не записали ни одного слова. Касайтесь подчёркнутых слов в текстах.';

  @override
  String get revealWipe => 'Протрите пальцем.';

  @override
  String get revealRub => 'Заштрихуйте карандашом: потрите пальцем.';

  @override
  String get wordTapTip => 'Коснитесь подчёркнутого слова, чтобы записать его.';

  @override
  String get crankInstruction => 'Крутите рукоятку по кругу.';

  @override
  String get mapTitle => 'Карта историй';

  @override
  String get mapHint =>
      'Каждая булавка — история. Разведите пальцы, чтобы приблизить.';

  @override
  String get settingsShowFps => 'Показывать частоту кадров (FPS)';
}
