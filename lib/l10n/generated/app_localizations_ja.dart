// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => 'つづきから';

  @override
  String get menuNewGame => 'はじめから';

  @override
  String get menuSettings => '設定';

  @override
  String get navLeft => '左を向く';

  @override
  String get navRight => '右を向く';

  @override
  String get navBack => '戻る';

  @override
  String get contentLoadError => 'ゲームのデータを読み込めませんでした。';

  @override
  String get backToMenu => 'メニューに戻る';

  @override
  String get examineItem => '調べる';

  @override
  String get closeExamine => '閉じる';

  @override
  String get inventoryLabel => '持ち物';

  @override
  String get closePuzzle => '閉じる';

  @override
  String get dialNext => '次の記号';

  @override
  String get dialPrevious => '前の記号';

  @override
  String get newGameConfirmTitle => 'はじめからにしますか？';

  @override
  String get newGameConfirmBody => 'このエピソードの進行状況は失われます。';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionStartOver => 'はじめからにする';

  @override
  String get saveCorruptedTitle => 'セーブデータを読み込めません';

  @override
  String get saveCorruptedBody => 'セーブデータが破損しているため、続きから遊べません。はじめから遊ぶことができます。';

  @override
  String get settingsMusicVolume => '音楽の音量';

  @override
  String get settingsSfxVolume => '効果音の音量';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageDevice => '端末の言語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => '振動';

  @override
  String get settingsResetProgress => '進行状況をリセット';

  @override
  String get resetConfirmTitle => 'すべての進行状況をリセットしますか？';

  @override
  String get resetConfirmBody => '保存された進行状況はすべて削除されます。設定はそのまま残ります。';

  @override
  String get actionReset => 'リセット';

  @override
  String get progressResetDone => '進行状況をリセットしました。';

  @override
  String get episodeComplete => '物語は蒸留された';

  @override
  String get hintButton => 'ヒント';

  @override
  String get hintTitle => 'ヒント';

  @override
  String get hintRevealNext => 'ヒントを見る';

  @override
  String get hintNoneAvailable => '今はヒントがありません。';

  @override
  String get hintAllShown => '今出せるヒントはこれで全部です。';

  @override
  String get actionClose => '閉じる';

  @override
  String get menuTagline => 'どの瓶にも、忘れてはならない物語が眠っている。';

  @override
  String get shelfTitle => '棚';

  @override
  String get shelfHint => '瓶を選んで、その物語を開こう。';

  @override
  String get jarSealed => 'まだ封印されている';

  @override
  String get jarDistilled => '蒸留済み';

  @override
  String get jarUnfinished => 'この物語はまだ終わっていません。';

  @override
  String get actionContinue => 'つづきから';

  @override
  String get actionOpenJar => '瓶を開ける';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => 'まだ開かない';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この瓶を開けるには、あと$countつの物語を蒸留しよう。',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling => '次のヒントのろうそくは、まだ灯りきっていない。もう少し探してみよう。';

  @override
  String get keeperNoteTitle => '番人の覚え書き';

  @override
  String get keeperNoteFound => '番人の覚え書きをひとつ見つけた。';

  @override
  String wordNoted(String word) {
    return '書き留めた：$word';
  }

  @override
  String get deductionInstruction => '瓶のラベルを書こう。空欄をタップし、書き留めた言葉を選ぶ。';

  @override
  String get deductionCheck => '蒸留する';

  @override
  String get deductionIncomplete => 'まだ空欄がある。';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'まだ$countつが正しくない。',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => 'どこかが正しくない。';

  @override
  String get deductionNoWords => 'まだ何も書き留めていない。読んだ文の下線付きの言葉をタップしよう。';

  @override
  String get revealWipe => '指でぬぐおう。';

  @override
  String get revealRub => '鉛筆でこすろう。指でなぞる。';

  @override
  String get wordTapTip => '下線付きの言葉をタップすると書き留められる。';

  @override
  String get crankInstruction => '取っ手をぐるぐる回そう。';

  @override
  String get mapTitle => '物語の地図';

  @override
  String get mapHint => 'ピンのひとつひとつが物語。指で広げて近づこう。';

  @override
  String get settingsShowFps => 'フレームレート（FPS）を表示';

  @override
  String get lensRaise => 'レンズをかざす';

  @override
  String get lensLower => 'レンズを下ろす';

  @override
  String get overlayInstruction => 'かけらをドラッグしよう。タップすると回せる。';

  @override
  String get deductionCorrectionInstruction =>
      'このうちいくつかの言葉がまちがっている。ひとつタップして、正しい言葉を選ぼう。「蒸留する」で確かめる。';

  @override
  String get telegramHeader => '電報';

  @override
  String get telegramStop => '';

  @override
  String get clockHandsInstruction => '針をドラッグして文字盤を回そう。';

  @override
  String get threadInstruction => 'ピンからピンへ糸を引こう。';

  @override
  String get rakingLightInstruction => 'ランプを板のまわりで、低く近くに動かそう。';

  @override
  String get beamSweepInstruction => '光の帯を見よう。照らされているうちに、見えたものをタップ。';

  @override
  String get beamSweepMiss => 'そこは暗すぎる。光が来るのを待とう。';

  @override
  String get swellInstruction => 'タップで一段おりる。海を見て、耳をすまそう。';

  @override
  String get swellCaught => '波に押されて、階段の上まで戻された。';

  @override
  String get rosterInstruction => 'ますをタップして変えよう。';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '見つけたことと合わない行が$countつある。',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => '国王の命により';

  @override
  String get keyringInstruction => '輪から鍵を一本取ろう。';

  @override
  String get keyringHand => '鍵をタップで裏返し、錠をタップで試そう。';

  @override
  String get keyringWrong => '回らない。';

  @override
  String get cipherInstruction => '手紙の数字をタップし、作業表の同じ数字をタップしよう。';

  @override
  String get sourcesInstruction => '書類をタップし、入るべき箱をタップしよう。';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '違う箱に入っている書類が$count枚ある。',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => '青銅からとった拓本';

  @override
  String get pourInstruction => '水路を回してから、炉を開けよう。';

  @override
  String get pourButton => '注ぐ';

  @override
  String get pourSpilt => '青銅が砂に流れ出た。炉がまた閉じられる。';

  @override
  String get pourShort => 'こぼれはしないが、空の湯口がある。';

  @override
  String get resonanceInstruction => '撞木を引いて放そう。下の穴を掘るか、埋めよう。';

  @override
  String get resonanceDeeper => '深く';

  @override
  String get resonanceShallower => '浅く';

  @override
  String get resonanceWeak => '弱すぎる。撞木が青銅にほとんど触れない。';

  @override
  String get resonanceShort => '響きが印の前で消える。';

  @override
  String get beatInstruction => '縁を撞こう。うなりが最も深い場所を探して、印をつけよう。';

  @override
  String get beatMark => 'ここに印をつける';

  @override
  String get beatWrong => 'ここではない。もっと深くうなる場所がある。';

  @override
  String get docketHeader => 'ロンドン警視庁';

  @override
  String get docketSubheader => '犯罪捜査部';

  @override
  String get unwatchedInstruction => '目をそらして、もう一度見よう。';

  @override
  String get unwatchedFind => '棚に新しいものがある。見つけよう。';

  @override
  String get unwatchedWrong => 'それは前からあった。';

  @override
  String get unwatchedLookAway => '目をそらす';

  @override
  String unwatchedProgress(int found, int total) {
    return '新しい綴り：$found / $total';
  }

  @override
  String get composeInstruction => '活字ケースから彼女の名前を組もう。活字は鏡文字に彫られている。';

  @override
  String get composeTakeOut => '取り出す';

  @override
  String get composeWrong => '試し刷りがどこか違っている。';

  @override
  String get strandInstruction => '区切りをタップして測る。それぞれの髪でいちばん高い値を見つけ、印をつけよう。';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$count回',
      zero: 'もう測れない',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => '最高として印をつける';

  @override
  String get strandWrong => 'いちばん高くはない。隣の区切りのほうが高いかもしれない。';

  @override
  String get strandNewSample => '新しい試料';

  @override
  String get strandOut => 'この試料に使える原子炉の時間はもうない。新しい試料を取ろう。';

  @override
  String get strandCurveQuestion => 'ヒ素は髪に沿ってどう分布している？';

  @override
  String get strandSteady => '何年にもわたって一定';

  @override
  String get strandPeak => '鋭い山がいくつか';

  @override
  String get strandCurveWrong => 'いちばん高い値のまわりをもう一度見よう。';

  @override
  String get scanInstruction => '探針を衣の上で動かそう。針が赤に入る場所に印をつける。';

  @override
  String get scanMark => 'ここに印';

  @override
  String get scanWrong => 'ここでは針はほとんど動かない。';

  @override
  String get scanFaint => '針は動くが、赤には届かない。この布越しでは弱すぎる？';

  @override
  String get scanAgain => 'もう印がある。';

  @override
  String scanFound(String place) {
    return '印をつけた：$place';
  }

  @override
  String scanProgress(int found, int total) {
    return '印をつけた場所：$found／$total';
  }

  @override
  String get vermilionCaption => '朱筆にて';

  @override
  String get quireInstruction =>
      '紙に触れ、次に別の紙に触れると、折丁の中で入れ替わる。紙を裏返すと二枚の葉が入れ替わる。つなぎ言葉がすべて次のページに出会うように。';

  @override
  String get quireTurn => '裏返す';

  @override
  String quireLinks(int count, int total) {
    return 'つなぎ言葉 $total のうち $count が合っている';
  }

  @override
  String get quirePicked => '別の紙に触れて入れ替えるか、この紙を裏返そう。';

  @override
  String get dipInstruction => '葦の棒を槽の中へ引き下ろし、水面に触れたら離して、したたり方を見よう。';

  @override
  String get dipWhat => '棒から何がしたたる？';

  @override
  String get dipWrong => 'そのしたたり方ではない。';

  @override
  String dipLevel(int percent) {
    return '$percent% まで満ちている';
  }

  @override
  String get dipStoresQuestion => 'すべての槽に名がついた。蓄えは尽きかけていたか、満ちていたか？';

  @override
  String get dipLow => '尽きかけていた';

  @override
  String get dipFull => '満ちていた';

  @override
  String get dipStoresWrong => 'それぞれの槽がどこまで満ちているか、もう一度見よう。';

  @override
  String get colophonCaption => 'ここに書は終わる';

  @override
  String get coursesInstruction =>
      '落ちた石材を、左から一段ずつ積み直そう。下の段の継ぎ目の上で石材を終わらせてはいけない。';

  @override
  String coursesCourse(int course, int total) {
    return '$total段のうち$course段目';
  }

  @override
  String get coursesTooLong => '長すぎる。隙間からはみ出してしまう。';

  @override
  String get coursesJoint => '継ぎ目の上に継ぎ目。そこで壁が割れてしまう。';

  @override
  String get coursesTakeBack => '取り戻す';

  @override
  String get coursesBand => 'シェブロンの帯。石板に触れると傾きが逆になる。交互に傾くまで続けよう。';

  @override
  String get identifyInstruction => '小片を見よう。どちらが正しい？';

  @override
  String identifyWrong(String name) {
    return '検索表の行き着いた先：$name';
  }

  @override
  String get identifyBack => '道を誤ったところへ戻る。';

  @override
  String get cartoucheCaption => '内陸部の新しい地図';

  @override
  String get snowpitInstruction => '層に触れてから、何かを押し込もう。入るもののうち最も大きいものが、その硬さを示す。';

  @override
  String snowpitIn(String tool) {
    return '$tool：入る';
  }

  @override
  String snowpitOut(String tool) {
    return '$tool：入らない';
  }

  @override
  String get snowpitMark => '弱層として印をつける';

  @override
  String get snowpitUntested => 'まずこの層と、その上の層の硬さを調べよう。';

  @override
  String get snowpitNotSofter => '上の層より柔らかくない。';

  @override
  String get snowpitTap => '叩く';

  @override
  String snowpitTaps(int count, String phase) {
    return '叩いた回数：$count（$phase）';
  }

  @override
  String get snowpitWrist => '手首から';

  @override
  String get snowpitElbow => '肘から';

  @override
  String get snowpitShoulder => '肩から';

  @override
  String get snowpitColumn => '印をつけた層のすぐ下まで柱を切り出した。上からシャベルを叩こう。';

  @override
  String get snowpitSpent => '三十回叩いても何も折れない。弱層はもっと深い。';

  @override
  String get snowpitBrokeElsewhere => '別の、もっと上の層で折れた。そちらに印をつけよう。';

  @override
  String get toolFist => 'こぶし';

  @override
  String get toolFourFingers => '指四本';

  @override
  String get toolOneFinger => '指一本';

  @override
  String get toolPencil => '鉛筆';

  @override
  String get toolKnife => 'ナイフ';

  @override
  String get darkroomInstruction => 'コマを選ぼう。そのテストストリップで、焼き付ける帯に触れよう。';

  @override
  String get darkroomLight => '短すぎる。灰色で空っぽだ。印画紙が無駄になった。';

  @override
  String get darkroomDark => '長すぎる。雪が灰色になった。印画紙が無駄になった。';

  @override
  String darkroomSeconds(String seconds) {
    return '$seconds秒';
  }

  @override
  String get routebookCaption => 'ルート帳';

  @override
  String get strataInstruction =>
      '出土品に触れて年を読もう。次に層に触れ、ありうる最も古い年を付けよう。その中で一番新しい出土品より古くはなく、下の層より古くもない。';

  @override
  String strataNotBefore(int year) {
    return '$year年以降';
  }

  @override
  String get strataWrong => 'その年はこの層に合わない。';

  @override
  String get strataFireQuestion => 'すべての層に年代が付いた。1582年の火災の層に触れよう。';

  @override
  String get strataFire => 'これが火災だ';

  @override
  String get strataNotBurnt => 'この層は燃えていない。';

  @override
  String get strataTooLate => 'この火事は1582年より後だ。';

  @override
  String get streetsInstruction => '上ル：北。下ル：南。東入ル：東。西入ル：西。所在地が示す街区に触れよう。';

  @override
  String get streetsWrong => 'この街区ではない。交差点からもう一度読もう。';

  @override
  String streetsProgress(int found, int total) {
    return '見つけた所在地：$totalのうち$found';
  }

  @override
  String get markerCaption => '史跡';

  @override
  String get ringsInstruction => 'コアを基準年輪曲線に沿って滑らせ、広い輪と狭い輪の並びが合ったら照合しよう。';

  @override
  String get ringsCheck => '照合する';

  @override
  String get ringsWrong => 'ここでは模様が合わない。さらに滑らせよう。';

  @override
  String ringsDated(int count) {
    return '年代が決まった。続く$count本の最も狭い輪に印を付けよう。最も乾いた年だ。';
  }

  @override
  String get ringsMark => 'これが最も乾いた年だ';

  @override
  String get ringsMarkWrong => '最も狭い並びではない。コアをもう一度見よう。';

  @override
  String get dividersInstruction =>
      '縮尺でディバイダーを開き、方角を選び、ロアノークから歩ませよう。止まった所に印を付けよう。';

  @override
  String get dividersHeadings => '北,北東,東,南東,南,南西,西,北西';

  @override
  String dividersSpan(int miles) {
    return '$milesマイル';
  }

  @override
  String get dividersStep => '一歩';

  @override
  String get dividersBack => '戻る';

  @override
  String get dividersMark => 'ここに印';

  @override
  String dividersWalked(int miles) {
    return '$milesマイル進んだ';
  }

  @override
  String get dividersElsewhere => '海図の別の場所だ。手がかりが示す所ではない。';

  @override
  String get dividersNothing => '海図のそこには何も描かれていない。';

  @override
  String dividersProgress(int found, int total) {
    return '見つけた場所：$totalのうち$found';
  }

  @override
  String get dividersUnset => 'ディバイダーを開いて方角を選び、それから歩ませよう。';

  @override
  String get postCaption => '秘密の目印';

  @override
  String get marginsInstruction => '紙を回して文が正立したら、問いに答える文に触れよう。';

  @override
  String get marginsUnreadable => 'その文は横向きか逆さまだ。紙を回そう。';

  @override
  String get marginsWrong => 'その文は答えになっていない。';

  @override
  String marginsProgress(int answered, int total) {
    return '回答：$totalのうち$answered';
  }

  @override
  String get sonarInstruction =>
      '測線に触れるとソナーがその上を走る。一本につき一時間。走らせた測線の上で沈没船に印を付けよう。';

  @override
  String sonarHours(int hours) {
    return '残り時間：$hours';
  }

  @override
  String get sonarRock => '岩：丸い反響、短い影。';

  @override
  String get sonarScour => '氷の削り跡：長い溝、立ち上がる影はない。';

  @override
  String get sonarNothing => '何もない海底。';

  @override
  String get sonarUnrun => 'そこの測線はまだ走らせていない。';

  @override
  String get sonarSpent => '季節が終わり、沈没船は見つからなかった。';

  @override
  String get sonarNextSeason => '次の季節';

  @override
  String get admiraltyCaption => 'この紙を見つけた方は、ロンドンの海軍本部長官あてに送付されたい';
}
