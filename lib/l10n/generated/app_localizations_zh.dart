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

  @override
  String get settingsShowFps => '显示帧率（FPS）';

  @override
  String get lensRaise => '举起透镜';

  @override
  String get lensLower => '放下透镜';

  @override
  String get overlayInstruction => '拖动碎片。轻点一块可以旋转它。';

  @override
  String get deductionCorrectionInstruction =>
      '其中有些词是错的。轻点一个，再点应该在那里的词。“蒸馏”来检查。';

  @override
  String get telegramHeader => '电报';

  @override
  String get telegramStop => '';

  @override
  String get clockHandsInstruction => '拖动指针绕着表盘转。';

  @override
  String get threadInstruction => '把线从一枚图钉拉到另一枚。';

  @override
  String get rakingLightInstruction => '把油灯绕着蜡板移动，放低，靠近。';

  @override
  String get beamSweepInstruction => '看着光束。趁它照亮时，点一下它照出的东西。';

  @override
  String get beamSweepMiss => '那里太暗了。等光束转过来。';

  @override
  String get swellInstruction => '点一下就往下走一级台阶。看着海，也听着海。';

  @override
  String get swellCaught => '海浪把你逼回了台阶顶上。';

  @override
  String get rosterInstruction => '点一下格子来更改。';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有$count行和你的发现对不上。',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => '奉国王之命';

  @override
  String get keyringInstruction => '从钥匙圈上取下一把钥匙。';

  @override
  String get keyringHand => '点钥匙把它翻过来；点锁来试一试。';

  @override
  String get keyringWrong => '转不动。';

  @override
  String get cipherInstruction => '点信里的一个数字，再点工作表上相同的数字。';

  @override
  String get sourcesInstruction => '点一份文件，再点它该放的托盘。';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有$count份文件放错了托盘。',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => '从青铜上拓下的拓片';

  @override
  String get pourInstruction => '转动沟槽，然后打开熔炉。';

  @override
  String get pourButton => '浇铸';

  @override
  String get pourSpilt => '铜水流进了沙里。熔炉又关上了。';

  @override
  String get pourShort => '没有洒出来，但有一个浇口是空的。';

  @override
  String get resonanceInstruction => '把撞木往后拉，再松手。把下面的坑挖深或填浅。';

  @override
  String get resonanceDeeper => '挖深';

  @override
  String get resonanceShallower => '填浅';

  @override
  String get resonanceWeak => '太轻了：撞木几乎碰不到青铜。';

  @override
  String get resonanceShort => '余音在标记前就消失了。';

  @override
  String get beatInstruction => '敲击钟口。找出余音起伏最深的地方，做上记号。';

  @override
  String get beatMark => '在这里做记号';

  @override
  String get beatWrong => '不是这里：别处起伏更深。';

  @override
  String get docketHeader => '伦敦警察厅';

  @override
  String get docketSubheader => '刑事调查部';

  @override
  String get unwatchedInstruction => '移开视线，再看回来。';

  @override
  String get unwatchedFind => '架子上多了点什么。找出来。';

  @override
  String get unwatchedWrong => '那一份本来就在。';

  @override
  String get unwatchedLookAway => '移开视线';

  @override
  String unwatchedProgress(int found, int total) {
    return '找到的新卷宗：$found / $total';
  }

  @override
  String get composeInstruction => '从字盘里排出她的名字。铅字是反着刻的。';

  @override
  String get composeTakeOut => '取出';

  @override
  String get composeWrong => '校样有地方不对。';

  @override
  String get strandInstruction => '点一段来测量。找出每根头发读数最高的一段，做上标记。';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还能测$count次',
      zero: '没有测量次数了',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => '标为最高';

  @override
  String get strandWrong => '这不是最高的。旁边的一段也许更高。';

  @override
  String get strandNewSample => '新样本';

  @override
  String get strandOut => '这份样本的反应堆时间用完了。换一份新样本。';

  @override
  String get strandCurveQuestion => '砷沿着头发是怎样分布的？';

  @override
  String get strandSteady => '多年平稳';

  @override
  String get strandPeak => '陡峭的峰值';

  @override
  String get strandCurveWrong => '再看看最高那段周围的读数。';

  @override
  String get scanInstruction => '在龙袍上拖动探头。指针进入红区的地方，做上标记。';

  @override
  String get scanMark => '标记这里';

  @override
  String get scanWrong => '这里指针几乎不动。';

  @override
  String get scanFaint => '指针动了，却没进红区。隔着这层衣料太弱了？';

  @override
  String get scanAgain => '已经标过了。';

  @override
  String scanFound(String place) {
    return '已标记：$place';
  }

  @override
  String scanProgress(int found, int total) {
    return '已标记：$found／$total处';
  }

  @override
  String get vermilionCaption => '朱批';
}
