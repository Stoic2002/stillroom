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

  @override
  String get lensRaise => 'Поднять линзу';

  @override
  String get lensLower => 'Опустить линзу';

  @override
  String get overlayInstruction =>
      'Перетаскивайте части. Коснитесь, чтобы повернуть.';

  @override
  String get deductionCorrectionInstruction =>
      'Некоторые слова здесь неверны. Коснитесь одного, затем нужного слова. «Перегнать» проверит.';

  @override
  String get telegramHeader => 'ТЕЛЕГРАММА';

  @override
  String get telegramStop => 'ТЧК';

  @override
  String get clockHandsInstruction => 'Двигайте стрелки по циферблату.';

  @override
  String get threadInstruction => 'Протяните нить от булавки к булавке.';

  @override
  String get rakingLightInstruction =>
      'Водите светильник вокруг таблички, низко и близко.';

  @override
  String get beamSweepInstruction =>
      'Следите за лучом. Нажмите на то, что он освещает, пока светло.';

  @override
  String get beamSweepMiss => 'Там слишком темно. Дождитесь луча.';

  @override
  String get swellInstruction =>
      'Нажмите, чтобы спуститься на ступень. Смотрите на море и слушайте.';

  @override
  String get swellCaught => 'Море загоняет вас обратно наверх.';

  @override
  String get rosterInstruction => 'Нажмите на клетку, чтобы изменить её.';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count строк не сходятся с тем, что вы нашли.',
      few: '$count строки не сходятся с тем, что вы нашли.',
      one: 'Одна строка не сходится с тем, что вы нашли.',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => 'По приказу короля';

  @override
  String get keyringInstruction => 'Снимите ключ со связки.';

  @override
  String get keyringHand =>
      'Нажмите на ключ, чтобы перевернуть его; на замок — чтобы попробовать.';

  @override
  String get keyringWrong => 'Не поворачивается.';

  @override
  String get cipherInstruction =>
      'Нажмите на число в письме, затем на то же число в таблице.';

  @override
  String get sourcesInstruction =>
      'Нажмите на бумагу, затем на лоток, где ей место.';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бумаг лежат не в том лотке.',
      few: '$count бумаги лежат не в том лотке.',
      one: 'Одна бумага лежит не в том лотке.',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => 'Оттиск с бронзы';

  @override
  String get pourInstruction => 'Поверните желоба, затем откройте печи.';

  @override
  String get pourButton => 'Лить';

  @override
  String get pourSpilt => 'Бронза уходит в песок. Печи снова закрывают.';

  @override
  String get pourShort => 'Ничего не пролилось, но одна чаша осталась пустой.';

  @override
  String get resonanceInstruction =>
      'Оттяните било и отпустите. Углубите или засыпьте яму под колоколом.';

  @override
  String get resonanceDeeper => 'Глубже';

  @override
  String get resonanceShallower => 'Мельче';

  @override
  String get resonanceWeak => 'Слишком слабо: бревно едва касается бронзы.';

  @override
  String get resonanceShort => 'Звон затихает, не дойдя до метки.';

  @override
  String get beatInstruction =>
      'Бейте по краю. Найдите, где звон нарастает и спадает глубже всего, и отметьте.';

  @override
  String get beatMark => 'Отметить это место';

  @override
  String get beatWrong => 'Не здесь: где-то волна глубже.';

  @override
  String get docketHeader => 'Столичная полиция';

  @override
  String get docketSubheader => 'Департамент уголовных расследований';

  @override
  String get unwatchedInstruction => 'Отвернитесь и посмотрите снова.';

  @override
  String get unwatchedFind => 'На полке появилось что-то новое. Найдите.';

  @override
  String get unwatchedWrong => 'Эта папка уже была.';

  @override
  String get unwatchedLookAway => 'Отвернуться';

  @override
  String unwatchedProgress(int found, int total) {
    return 'Новых папок найдено: $found из $total';
  }

  @override
  String get composeInstruction =>
      'Наберите её имя из кассы. Литеры вырезаны зеркально.';

  @override
  String get composeTakeOut => 'Вынуть';

  @override
  String get composeWrong => 'Оттиск где-то неверен.';

  @override
  String get strandInstruction =>
      'Нажмите на отрезок, чтобы измерить его. Найдите самое высокое показание на каждой пряди и отметьте его.';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count замера',
      many: 'Осталось $count замеров',
      few: 'Осталось $count замера',
      one: 'Остался $count замер',
      zero: 'Замеров не осталось',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => 'Отметить как самый высокий';

  @override
  String get strandWrong =>
      'Это не самый высокий. Соседний отрезок может показать больше.';

  @override
  String get strandNewSample => 'Новый образец';

  @override
  String get strandOut =>
      'Время реактора для этого образца кончилось. Возьмите новый.';

  @override
  String get strandCurveQuestion => 'Как мышьяк распределён вдоль волоса?';

  @override
  String get strandSteady => 'Ровно, годами';

  @override
  String get strandPeak => 'Резкие пики';

  @override
  String get strandCurveWrong =>
      'Посмотрите ещё раз на показания рядом с самым высоким.';

  @override
  String get scanInstruction =>
      'Ведите зонд по одеянию. Отмечайте места, где стрелка уходит в красное.';

  @override
  String get scanMark => 'Отметить здесь';

  @override
  String get scanWrong => 'Здесь стрелка почти не движется.';

  @override
  String get scanFaint =>
      'Стрелка дрогнула, но до красного не дошла. Сквозь эту ткань слишком слабо?';

  @override
  String get scanAgain => 'Уже отмечено.';

  @override
  String scanFound(String place) {
    return 'Отмечено: $place';
  }

  @override
  String scanProgress(int found, int total) {
    return 'Отмечено мест: $found из $total';
  }

  @override
  String get vermilionCaption => 'Киноварью';

  @override
  String get quireInstruction =>
      'Коснитесь листа, потом другого, чтобы поменять их местами в тетради. Переверните лист, чтобы поменять местами его половины. Каждая кустода должна встретить свою страницу.';

  @override
  String get quireTurn => 'Перевернуть';

  @override
  String quireLinks(int count, int total) {
    return 'Кустод на своих местах: $count из $total';
  }

  @override
  String get quirePicked =>
      'Коснитесь другого листа, чтобы поменять их местами, или переверните этот.';

  @override
  String get dipInstruction =>
      'Опустите тростинку в водоём, пока она не коснётся поверхности, затем отпустите и посмотрите, как с неё капает.';

  @override
  String get dipWhat => 'Что капает с тростинки?';

  @override
  String get dipWrong => 'Оно капает не так.';

  @override
  String dipLevel(int percent) {
    return 'Полон на $percent%';
  }

  @override
  String get dipStoresQuestion =>
      'Все водоёмы названы. Припасы подходили к концу или были полны?';

  @override
  String get dipLow => 'Подходили к концу';

  @override
  String get dipFull => 'Были полны';

  @override
  String get dipStoresWrong =>
      'Посмотрите ещё раз, насколько полон каждый водоём.';

  @override
  String get colophonCaption => 'Здесь кончается книга';

  @override
  String get coursesInstruction =>
      'Уложите упавшие блоки обратно, ряд за рядом, слева. Ни один блок не должен кончаться над швом нижнего ряда.';

  @override
  String coursesCourse(int course, int total) {
    return 'Ряд $course из $total';
  }

  @override
  String get coursesTooLong => 'Слишком длинный: выйдет за пролом.';

  @override
  String get coursesJoint => 'Шов над швом: стена треснет здесь.';

  @override
  String get coursesTakeBack => 'Вернуть';

  @override
  String get coursesBand =>
      'Полоса шевронов: коснитесь плиты, чтобы наклонить её в другую сторону, пока они не наклонятся поочерёдно.';

  @override
  String get identifyInstruction => 'Посмотрите на щепку. Что о ней верно?';

  @override
  String identifyWrong(String name) {
    return 'Определитель привёл к: $name';
  }

  @override
  String get identifyBack => 'Назад, туда, где путь свернул не туда.';

  @override
  String get cartoucheCaption => 'Новая карта внутренних земель';
}
