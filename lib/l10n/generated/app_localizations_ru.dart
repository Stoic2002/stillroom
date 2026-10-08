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

  @override
  String get snowpitInstruction =>
      'Коснитесь слоя, затем вдавите в него что-нибудь: самое большое, что входит, и есть его твёрдость.';

  @override
  String snowpitIn(String tool) {
    return '$tool: входит';
  }

  @override
  String snowpitOut(String tool) {
    return '$tool: не входит';
  }

  @override
  String get snowpitMark => 'Отметить как слабый';

  @override
  String get snowpitUntested =>
      'Сначала узнайте твёрдость этого слоя и слоя над ним.';

  @override
  String get snowpitNotSofter => 'Он не мягче слоя над ним.';

  @override
  String get snowpitTap => 'Удар';

  @override
  String snowpitTaps(int count, String phase) {
    return 'Удары: $count ($phase)';
  }

  @override
  String get snowpitWrist => 'от запястья';

  @override
  String get snowpitElbow => 'от локтя';

  @override
  String get snowpitShoulder => 'от плеча';

  @override
  String get snowpitColumn =>
      'Колонна вырезана до самого низа отмеченного слоя. Ударяйте лопатой сверху.';

  @override
  String get snowpitSpent =>
      'Тридцать ударов, и ничего не сломалось: слабый слой глубже.';

  @override
  String get snowpitBrokeElsewhere =>
      'Сломалось на другом слое, выше. Отметьте его.';

  @override
  String get toolFist => 'Кулак';

  @override
  String get toolFourFingers => 'Четыре пальца';

  @override
  String get toolOneFinger => 'Один палец';

  @override
  String get toolPencil => 'Карандаш';

  @override
  String get toolKnife => 'Нож';

  @override
  String get darkroomInstruction =>
      'Выберите кадр. На его пробной полоске коснитесь полосы, с которой печатать.';

  @override
  String get darkroomLight =>
      'Слишком коротко: серо и пусто. Бумага испорчена.';

  @override
  String get darkroomDark => 'Слишком долго: снег посерел. Бумага испорчена.';

  @override
  String darkroomSeconds(String seconds) {
    return '$seconds с';
  }

  @override
  String get routebookCaption => 'Маршрутная книжка';

  @override
  String get strataInstruction =>
      'Коснитесь находки, чтобы прочесть её год. Потом коснитесь слоя и дайте ему самый ранний возможный год: не старше самой поздней находки в нём и не старше слоя под ним.';

  @override
  String strataNotBefore(int year) {
    return 'Не раньше $year';
  }

  @override
  String get strataWrong => 'Эта дата не подходит слою.';

  @override
  String get strataFireQuestion =>
      'Все слои датированы. Коснитесь слоя пожара 1582 года.';

  @override
  String get strataFire => 'Это пожар';

  @override
  String get strataNotBurnt => 'Этот слой не горел.';

  @override
  String get strataTooLate => 'Этот пожар позже 1582 года.';

  @override
  String get streetsInstruction =>
      'Агару — север. Сагару — юг. Хигаси-иру — восток. Ниси-иру — запад. Коснитесь квартала, названного адресом.';

  @override
  String get streetsWrong =>
      'Не этот квартал. Прочтите адрес снова от перекрёстка.';

  @override
  String streetsProgress(int found, int total) {
    return 'Найдено адресов: $found из $total';
  }

  @override
  String get markerCaption => 'Историческое место';

  @override
  String get ringsInstruction =>
      'Двигайте керн вдоль эталонной хронологии, пока широкие и узкие кольца не совпадут, затем сверьте.';

  @override
  String get ringsCheck => 'Сверить';

  @override
  String get ringsWrong => 'Здесь рисунок не совпадает. Двигайте дальше.';

  @override
  String ringsDated(int count) {
    return 'Датировано. Теперь отметьте $count самых узких колец подряд: самые сухие годы.';
  }

  @override
  String get ringsMark => 'Это самые сухие годы';

  @override
  String get ringsMarkWrong =>
      'Это не самый узкий ряд. Посмотрите на керн ещё раз.';

  @override
  String get dividersInstruction =>
      'Разведите циркуль по шкале, выберите курс и шагайте от Роанока. Отметьте, где он встал.';

  @override
  String get dividersHeadings => 'С,СВ,В,ЮВ,Ю,ЮЗ,З,СЗ';

  @override
  String dividersSpan(int miles) {
    return '$miles миль';
  }

  @override
  String get dividersStep => 'Шаг';

  @override
  String get dividersBack => 'Назад';

  @override
  String get dividersMark => 'Отметить здесь';

  @override
  String dividersWalked(int miles) {
    return 'Пройдено $miles миль';
  }

  @override
  String get dividersElsewhere =>
      'Это другое место на карте, не то, что названо в подсказке.';

  @override
  String get dividersNothing => 'Там на карте ничего не нарисовано.';

  @override
  String dividersProgress(int found, int total) {
    return 'Найдено мест: $found из $total';
  }

  @override
  String get dividersUnset =>
      'Разведите циркуль и выберите курс, потом шагайте.';

  @override
  String get postCaption => 'Условный знак';

  @override
  String get marginsInstruction =>
      'Поворачивайте лист, пока отрывок не встанет прямо, и коснитесь того, что отвечает на вопрос.';

  @override
  String get marginsUnreadable =>
      'Этот отрывок лежит боком или вверх ногами. Поверните лист.';

  @override
  String get marginsWrong => 'Этот отрывок на вопрос не отвечает.';

  @override
  String marginsProgress(int answered, int total) {
    return 'Отвечено: $answered из $total';
  }

  @override
  String get sonarInstruction =>
      'Коснитесь галса, чтобы пройти по нему сонаром, по часу на галс. Отметьте затонувшее судно на пройденном галсе.';

  @override
  String sonarHours(int hours) {
    return 'Осталось часов: $hours';
  }

  @override
  String get sonarRock => 'Камень: круглое эхо, короткая тень.';

  @override
  String get sonarScour => 'Ледовая борозда: длинный желоб без встающей тени.';

  @override
  String get sonarNothing => 'Голое дно.';

  @override
  String get sonarUnrun => 'Здесь галс ещё не пройден.';

  @override
  String get sonarSpent => 'Сезон закончился, а судно не найдено.';

  @override
  String get sonarNextSeason => 'Следующий сезон';

  @override
  String get admiraltyCaption =>
      'Нашедшего эту бумагу просят переслать её секретарю Адмиралтейства, Лондон';

  @override
  String get mudraInstruction =>
      'Коснитесь упавшего Будды, затем места, которому принадлежат его руки.';

  @override
  String get mudraWrong => 'Эти руки не принадлежат этому месту.';

  @override
  String get mudraFull => 'Там не осталось пустых ниш.';

  @override
  String mudraProgress(int set, int total) {
    return 'Возвращено: $set из $total';
  }

  @override
  String get casingInstruction =>
      'Поднимите камень, чтобы увидеть рельеф за ним. По два за раз: деяние и его плод остаются; остальные встают на место.';

  @override
  String get casingNoPair => 'Это не деяние и его плод. Камни встают на место.';

  @override
  String get casingPair => 'Деяние и его плод: сфотографированы.';

  @override
  String casingProgress(int kept, int total) {
    return 'Сфотографировано пар: $kept из $total';
  }

  @override
  String get casingDeed => 'Деяние';

  @override
  String get casingFruit => 'Плод';

  @override
  String get handsInstruction =>
      'Выберите рецепт, затем руку, которая его написала: смотрите на g, длинное s, «и» и наклон.';

  @override
  String get handsCheck => 'Проверить';

  @override
  String handsWrong(int count) {
    return 'Неверно отнесённых вернулось: $count.';
  }

  @override
  String handsSorted(int done, int total) {
    return 'Разобрано: $done из $total';
  }

  @override
  String get stillInstruction =>
      'Поддерживайте огонь, не перекрывайте холодную воду и переставляйте стакан, когда меняется капля: голова, сердце, хвост. Сохраните сердце.';

  @override
  String get stillFire => 'Огонь';

  @override
  String get stillFireOut => 'Погашен';

  @override
  String get stillFireGentle => 'Слабый';

  @override
  String get stillFireFierce => 'Сильный';

  @override
  String get stillWater => 'Холодная вода';

  @override
  String get stillWaterOn => 'Течёт';

  @override
  String get stillWaterOff => 'Перекрыта';

  @override
  String get stillGlassHeads => 'Голова';

  @override
  String get stillGlassHeart => 'Сердце';

  @override
  String get stillGlassTails => 'Хвост';

  @override
  String get stillDripHeads => 'Мутно и резко: голова.';

  @override
  String get stillDripHeart => 'Прозрачно и сладко: сердце.';

  @override
  String get stillDripTails => 'Маслянисто и тяжело: хвост.';

  @override
  String get stillIdle => 'Ничего не капает: огонь погашен.';

  @override
  String get stillDry => 'В чане нет воды: змеевик раскаляется!';

  @override
  String get stillSpoiled => 'Змеевик перегрелся, перегонка испорчена.';

  @override
  String get stillLost => 'Стакан сердца нечист или недостаточно полон.';

  @override
  String get stillReset => 'Вылить и начать снова';

  @override
  String get spectrumInstruction =>
      'Ведите лампу по её диапазонам, пока изображение не прояснится, и записывайте, что показывает каждый диапазон.';

  @override
  String get spectrumRecord => 'Записать';

  @override
  String get spectrumBlurred => 'В этом положении ничего не видно.';

  @override
  String get spectrumAlready => 'Эта пластина уже записана.';

  @override
  String spectrumRecorded(int count, int total) {
    return 'Записано пластин: $count из $total';
  }

  @override
  String get spectrumLayInstruction =>
      'Положите пластины на портрет в порядке жизни картины, начиная с самой ранней.';

  @override
  String get spectrumWrongOrder =>
      'Не в порядке жизни картины. Пластины возвращаются.';

  @override
  String get receiptCaption => 'Чтобы сохранить имя';
}
