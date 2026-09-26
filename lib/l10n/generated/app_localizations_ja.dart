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
}
