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

  @override
  String get quireInstruction =>
      '点一张，再点另一张，就能交换它们在书帖中的位置。把一张翻过来，它的两叶就会对调。每个接页词都要接上它的那一页。';

  @override
  String get quireTurn => '翻过来';

  @override
  String quireLinks(int count, int total) {
    return '$total 个接页词中有 $count 个接上了';
  }

  @override
  String get quirePicked => '点另一张来交换位置，或者把这一张翻过来。';

  @override
  String get dipInstruction => '把芦苇往池里拖，碰到液面后松手，看它怎样滴落。';

  @override
  String get dipWhat => '芦苇上滴下的是什么？';

  @override
  String get dipWrong => '滴落的样子不是这样。';

  @override
  String dipLevel(int percent) {
    return '满到 $percent%';
  }

  @override
  String get dipStoresQuestion => '每个池子都叫出了名字。存货是快见底了，还是满的？';

  @override
  String get dipLow => '快见底了';

  @override
  String get dipFull => '满的';

  @override
  String get dipStoresWrong => '再看看每个池子满到哪里。';

  @override
  String get colophonCaption => '此书至此终';

  @override
  String get coursesInstruction => '从左边开始，把掉落的石块一层一层砌回去。任何石块都不能在下一层的接缝上方结束。';

  @override
  String coursesCourse(int course, int total) {
    return '第$course层，共$total层';
  }

  @override
  String get coursesTooLong => '太长了：会超出缺口。';

  @override
  String get coursesJoint => '接缝对接缝：墙会从那里裂开。';

  @override
  String get coursesTakeBack => '撤回';

  @override
  String get coursesBand => '人字纹带：点一块石板让它向另一边倾斜，直到它们交替倾斜。';

  @override
  String get identifyInstruction => '看看这片木屑。哪一句符合它？';

  @override
  String identifyWrong(String name) {
    return '检索表走到了：$name';
  }

  @override
  String get identifyBack => '回到走错的地方。';

  @override
  String get cartoucheCaption => '内陆新图';

  @override
  String get snowpitInstruction => '点一层雪，再把东西推进去：能进去的最大的那样，就是它的硬度。';

  @override
  String snowpitIn(String tool) {
    return '$tool：能进去';
  }

  @override
  String snowpitOut(String tool) {
    return '$tool：进不去';
  }

  @override
  String get snowpitMark => '标为弱层';

  @override
  String get snowpitUntested => '先测出这一层和它上面那一层的硬度。';

  @override
  String get snowpitNotSofter => '它并不比上面那层软。';

  @override
  String get snowpitTap => '敲击';

  @override
  String snowpitTaps(int count, String phase) {
    return '敲击次数：$count（$phase）';
  }

  @override
  String get snowpitWrist => '用手腕';

  @override
  String get snowpitElbow => '用手肘';

  @override
  String get snowpitShoulder => '用肩膀';

  @override
  String get snowpitColumn => '雪柱已切到标记层的正下方。在上面敲铲子。';

  @override
  String get snowpitSpent => '敲了三十下，什么也没断：弱层还在更深处。';

  @override
  String get snowpitBrokeElsewhere => '它断在了另一层，更靠上。去标那一层。';

  @override
  String get toolFist => '拳头';

  @override
  String get toolFourFingers => '四根手指';

  @override
  String get toolOneFinger => '一根手指';

  @override
  String get toolPencil => '铅笔';

  @override
  String get toolKnife => '小刀';

  @override
  String get darkroomInstruction => '选一格。在它的试样条上，点要用来放印的那一段。';

  @override
  String get darkroomLight => '太短：灰白一片。相纸废了。';

  @override
  String get darkroomDark => '太长：雪发灰了。相纸废了。';

  @override
  String darkroomSeconds(String seconds) {
    return '$seconds秒';
  }

  @override
  String get routebookCaption => '路线手册';

  @override
  String get strataInstruction =>
      '点出土物，读出它的年份。再点一层土，给它可能的最早年份：不早于其中最晚的出土物，也不早于它下面的那一层。';

  @override
  String strataNotBefore(int year) {
    return '不早于$year年';
  }

  @override
  String get strataWrong => '这个年份对不上这一层。';

  @override
  String get strataFireQuestion => '每一层都定了年代。点出1582年那场火灾的土层。';

  @override
  String get strataFire => '就是这场火';

  @override
  String get strataNotBurnt => '这一层从没烧过。';

  @override
  String get strataTooLate => '这场火比1582年晚。';

  @override
  String get streetsInstruction => '上ル：北。下ル：南。东入ル：东。西入ル：西。点地址所说的那个街区。';

  @override
  String get streetsWrong => '不是这个街区。从路口重新读一遍地址。';

  @override
  String streetsProgress(int found, int total) {
    return '已找到的地址：$found/$total';
  }

  @override
  String get markerCaption => '史迹';

  @override
  String get ringsInstruction => '沿主年表滑动树芯，直到宽窄年轮的节奏对上，再核对。';

  @override
  String get ringsCheck => '核对';

  @override
  String get ringsWrong => '这里图样对不上。继续滑动。';

  @override
  String ringsDated(int count) {
    return '定年了。现在标出连续$count圈最窄的年轮：最干旱的年份。';
  }

  @override
  String get ringsMark => '这就是最干旱的年份';

  @override
  String get ringsMarkWrong => '不是最窄的一段。再沿树芯看看。';

  @override
  String get dividersInstruction => '在比例尺上张开分规，选一个方向，从罗阿诺克一步步量过去。在分规停下处做标记。';

  @override
  String get dividersHeadings => '北,东北,东,东南,南,西南,西,西北';

  @override
  String dividersSpan(int miles) {
    return '$miles英里';
  }

  @override
  String get dividersStep => '一步';

  @override
  String get dividersBack => '退回';

  @override
  String get dividersMark => '在此标记';

  @override
  String dividersWalked(int miles) {
    return '已量$miles英里';
  }

  @override
  String get dividersElsewhere => '海图上的另一个地方，不是线索说的那个。';

  @override
  String get dividersNothing => '海图上那里什么也没画。';

  @override
  String dividersProgress(int found, int total) {
    return '已找到地点：$found/$total';
  }

  @override
  String get dividersUnset => '先张开分规并选方向，再迈步。';

  @override
  String get postCaption => '秘密记号';

  @override
  String get marginsInstruction => '转动纸张，直到某段文字摆正，再点能回答问题的那一段。';

  @override
  String get marginsUnreadable => '那段字是侧着或倒着的。转一转纸。';

  @override
  String get marginsWrong => '那段字回答不了这个问题。';

  @override
  String marginsProgress(int answered, int total) {
    return '已回答：$answered/$total';
  }

  @override
  String get sonarInstruction => '点一条测线，让声呐沿它扫过，每条一小时。在已扫过的测线上标出沉船。';

  @override
  String sonarHours(int hours) {
    return '剩余时间：$hours小时';
  }

  @override
  String get sonarRock => '岩石：圆形回波，影子很短。';

  @override
  String get sonarScour => '冰擦痕：一道长沟，没有立起的影子。';

  @override
  String get sonarNothing => '空荡的海底。';

  @override
  String get sonarUnrun => '那里的测线还没扫过。';

  @override
  String get sonarSpent => '季节结束了，沉船仍未找到。';

  @override
  String get sonarNextSeason => '下一季';

  @override
  String get admiraltyCaption => '拾得此纸者，请转交伦敦海军部秘书';

  @override
  String get mudraInstruction => '点一尊倒下的佛像，再点它的手印所属的地方。';

  @override
  String get mudraWrong => '这个手印不属于那里。';

  @override
  String get mudraFull => '那里已经没有空龛了。';

  @override
  String mudraProgress(int set, int total) {
    return '已复位：$set/$total';
  }

  @override
  String get casingInstruction => '搬起一块石头，看后面的浮雕。一次两块：一个行为与它的果报就留下；其余放回。';

  @override
  String get casingNoPair => '不是一个行为与它的果报。石头放回原处。';

  @override
  String get casingPair => '一个行为与它的果报：拍下了。';

  @override
  String casingProgress(int kept, int total) {
    return '已拍下的组：$kept/$total';
  }

  @override
  String get casingDeed => '行为';

  @override
  String get casingFruit => '果报';
}
