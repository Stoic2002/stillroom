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
}
