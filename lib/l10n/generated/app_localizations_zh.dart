// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => '继续';

  @override
  String get menuNewGame => '新游戏';

  @override
  String get menuSettings => '设置';

  @override
  String get navLeft => '向左转';

  @override
  String get navRight => '向右转';

  @override
  String get navBack => '后退';

  @override
  String get contentLoadError => '无法加载游戏内容。';

  @override
  String get backToMenu => '返回菜单';

  @override
  String get examineItem => '查看';

  @override
  String get closeExamine => '关闭';

  @override
  String get inventoryLabel => '物品栏';

  @override
  String get closePuzzle => '关闭';

  @override
  String get dialNext => '下一个符号';

  @override
  String get dialPrevious => '上一个符号';

  @override
  String get newGameConfirmTitle => '开始新游戏？';

  @override
  String get newGameConfirmBody => '你在本章节的当前进度将会丢失。';

  @override
  String get actionCancel => '取消';

  @override
  String get actionStartOver => '重新开始';

  @override
  String get saveCorruptedTitle => '无法读取存档';

  @override
  String get saveCorruptedBody => '你的存档已损坏，无法继续。你可以开始新游戏。';

  @override
  String get settingsMusicVolume => '音乐音量';

  @override
  String get settingsSfxVolume => '音效音量';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageDevice => '跟随设备';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => '振动';

  @override
  String get settingsResetProgress => '重置进度';

  @override
  String get resetConfirmTitle => '重置全部进度？';

  @override
  String get resetConfirmBody => '所有已保存的进度都将被删除。你的设置会保留。';

  @override
  String get actionReset => '重置';

  @override
  String get progressResetDone => '进度已重置。';

  @override
  String get episodeComplete => '这个故事已被蒸馏';

  @override
  String get hintButton => '提示';

  @override
  String get hintTitle => '提示';

  @override
  String get hintRevealNext => '显示提示';

  @override
  String get hintNoneAvailable => '暂时没有提示。';

  @override
  String get hintAllShown => '目前的提示已全部显示。';

  @override
  String get actionClose => '关闭';

  @override
  String get menuTagline => '每一个瓶子里，都封存着一个不该被遗忘的故事。';

  @override
  String get shelfTitle => '架子';

  @override
  String get shelfHint => '选择一个瓶子，打开它的故事。';

  @override
  String get jarSealed => '尚未启封';

  @override
  String get jarDistilled => '已蒸馏';

  @override
  String get jarUnfinished => '这个故事你还没有讲完。';

  @override
  String get actionContinue => '继续';

  @override
  String get actionOpenJar => '打开瓶子';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => '尚未开启';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '再蒸馏$count个故事，即可打开这个瓶子。',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling => '下一条提示的蜡烛还没有点亮。再四处找找吧。';

  @override
  String get keeperNoteTitle => '看守者的字条';

  @override
  String get keeperNoteFound => '你找到了看守者的一张字条。';

  @override
  String wordNoted(String word) {
    return '已记下：$word';
  }

  @override
  String get deductionInstruction => '写下瓶子的标签：点一个空格，再点一个你记下的词。';

  @override
  String get deductionCheck => '蒸馏';

  @override
  String get deductionIncomplete => '还有空格没有填。';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '其中还有$count处不对。',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => '这里有些地方不对。';

  @override
  String get deductionNoWords => '你还没有记下任何词。点一下所读文字中带下划线的词。';

  @override
  String get revealWipe => '用手指擦一擦。';

  @override
  String get revealRub => '用铅笔涂一涂：用手指来回擦。';

  @override
  String get wordTapTip => '点一下带下划线的词，就能把它记下来。';

  @override
  String get crankInstruction => '握住把手，一圈又一圈地转动。';

  @override
  String get mapTitle => '故事地图';

  @override
  String get mapHint => '每一枚图钉都是一个故事。双指张开可放大。';
}
