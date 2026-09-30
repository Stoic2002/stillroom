// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Stillroom';

  @override
  String get menuContinue => '이어하기';

  @override
  String get menuNewGame => '새 게임';

  @override
  String get menuSettings => '설정';

  @override
  String get navLeft => '왼쪽으로 돌기';

  @override
  String get navRight => '오른쪽으로 돌기';

  @override
  String get navBack => '뒤로 물러나기';

  @override
  String get contentLoadError => '게임 콘텐츠를 불러오지 못했습니다.';

  @override
  String get backToMenu => '메뉴로 돌아가기';

  @override
  String get examineItem => '살펴보기';

  @override
  String get closeExamine => '닫기';

  @override
  String get inventoryLabel => '소지품';

  @override
  String get closePuzzle => '닫기';

  @override
  String get dialNext => '다음 기호';

  @override
  String get dialPrevious => '이전 기호';

  @override
  String get newGameConfirmTitle => '새 게임을 시작할까요?';

  @override
  String get newGameConfirmBody => '이 에피소드의 현재 진행 상황이 사라집니다.';

  @override
  String get actionCancel => '취소';

  @override
  String get actionStartOver => '처음부터';

  @override
  String get saveCorruptedTitle => '저장된 게임을 읽을 수 없습니다';

  @override
  String get saveCorruptedBody =>
      '저장된 진행 상황이 손상되어 이어할 수 없습니다. 새 게임을 시작할 수 있습니다.';

  @override
  String get settingsMusicVolume => '음악 음량';

  @override
  String get settingsSfxVolume => '효과음 음량';

  @override
  String get settingsLanguage => '언어';

  @override
  String get languageDevice => '기기 언어';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get settingsVibration => '진동';

  @override
  String get settingsResetProgress => '진행 상황 초기화';

  @override
  String get resetConfirmTitle => '모든 진행 상황을 초기화할까요?';

  @override
  String get resetConfirmBody => '저장된 모든 진행 상황이 삭제됩니다. 설정은 유지됩니다.';

  @override
  String get actionReset => '초기화';

  @override
  String get progressResetDone => '진행 상황을 초기화했습니다.';

  @override
  String get episodeComplete => '이야기가 증류되었다';

  @override
  String get hintButton => '힌트';

  @override
  String get hintTitle => '힌트';

  @override
  String get hintRevealNext => '힌트 보기';

  @override
  String get hintNoneAvailable => '지금은 힌트가 없습니다.';

  @override
  String get hintAllShown => '지금 볼 수 있는 힌트는 이것이 전부입니다.';

  @override
  String get actionClose => '닫기';

  @override
  String get menuTagline => '모든 유리병에는 잊혀서는 안 될 이야기가 담겨 있다.';

  @override
  String get shelfTitle => '선반';

  @override
  String get shelfHint => '유리병을 골라 그 이야기를 여세요.';

  @override
  String get jarSealed => '아직 봉인됨';

  @override
  String get jarDistilled => '증류됨';

  @override
  String get jarUnfinished => '이 이야기를 끝내지 않고 떠났습니다.';

  @override
  String get actionContinue => '이어하기';

  @override
  String get actionOpenJar => '유리병 열기';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageRussian => 'Русский';

  @override
  String get jarLockedTitle => '아직은 안 됩니다';

  @override
  String jarLocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이야기를 $count개 더 증류하면 이 유리병이 열립니다.',
    );
    return '$_temp0';
  }

  @override
  String get languageKorean => '한국어';

  @override
  String get hintKindling => '다음 힌트의 촛불이 아직 붙는 중입니다. 조금 더 둘러보세요.';

  @override
  String get keeperNoteTitle => '관리인의 쪽지';

  @override
  String get keeperNoteFound => '관리인의 쪽지 하나를 찾았습니다.';

  @override
  String wordNoted(String word) {
    return '기록함: $word';
  }

  @override
  String get deductionInstruction => '유리병의 라벨을 쓰세요. 빈칸을 누른 다음, 기록해 둔 낱말을 누르세요.';

  @override
  String get deductionCheck => '증류하기';

  @override
  String get deductionIncomplete => '아직 빈칸이 남아 있습니다.';

  @override
  String deductionNearMiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '그중 $count개가 아직 맞지 않습니다.',
    );
    return '$_temp0';
  }

  @override
  String get deductionWrong => '여기 무언가가 맞지 않습니다.';

  @override
  String get deductionNoWords => '아직 기록한 낱말이 없습니다. 읽은 글에서 밑줄 친 낱말을 누르세요.';

  @override
  String get revealWipe => '손가락으로 닦아 보세요.';

  @override
  String get revealRub => '연필로 칠해 보세요. 손가락으로 문지르세요.';

  @override
  String get wordTapTip => '밑줄 친 낱말을 누르면 기록할 수 있습니다.';

  @override
  String get crankInstruction => '손잡이를 계속 빙글빙글 돌리세요.';

  @override
  String get mapTitle => '이야기 지도';

  @override
  String get mapHint => '핀 하나하나가 이야기입니다. 두 손가락으로 벌려 확대하세요.';

  @override
  String get settingsShowFps => '프레임 속도(FPS) 표시';

  @override
  String get lensRaise => '렌즈 들기';

  @override
  String get lensLower => '렌즈 내리기';

  @override
  String get overlayInstruction => '조각을 끌어 옮기세요. 톡 치면 돌아갑니다.';

  @override
  String get deductionCorrectionInstruction =>
      '이 중 몇 단어는 틀렸습니다. 하나를 톡 치고, 그 자리에 맞는 단어를 고르세요. \'증류하기\'로 확인합니다.';

  @override
  String get telegramHeader => '전보';

  @override
  String get telegramStop => '';

  @override
  String get clockHandsInstruction => '바늘을 끌어 문자판을 돌리세요.';

  @override
  String get threadInstruction => '핀에서 핀으로 실을 이으세요.';

  @override
  String get rakingLightInstruction => '등잔을 판 둘레로, 낮고 가깝게 움직이세요.';

  @override
  String get beamSweepInstruction => '빛줄기를 지켜보세요. 빛이 비추는 동안 보이는 것을 누르세요.';

  @override
  String get beamSweepMiss => '거기는 너무 어둡습니다. 빛이 오기를 기다리세요.';

  @override
  String get swellInstruction => '누르면 한 계단 내려갑니다. 바다를 보고, 귀를 기울이세요.';

  @override
  String get swellCaught => '바다가 당신을 계단 위로 도로 밀어 올립니다.';

  @override
  String get rosterInstruction => '칸을 눌러 바꾸세요.';

  @override
  String rosterWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '찾아낸 것과 맞지 않는 줄이 $count개 있습니다.',
    );
    return '$_temp0';
  }

  @override
  String get orderHeader => 'De par le Roy';

  @override
  String get orderSubheader => '국왕의 명에 따라';

  @override
  String get keyringInstruction => '고리에서 열쇠 하나를 빼세요.';

  @override
  String get keyringHand => '열쇠를 눌러 뒤집고, 자물쇠를 눌러 넣어 보세요.';

  @override
  String get keyringWrong => '돌아가지 않는다.';

  @override
  String get cipherInstruction => '편지의 숫자를 누르고, 작업표에서 같은 숫자를 누르세요.';

  @override
  String get sourcesInstruction => '문서를 누르고, 들어갈 상자를 누르세요.';

  @override
  String sourcesWrong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '잘못된 상자에 든 문서가 $count장 있습니다.',
    );
    return '$_temp0';
  }

  @override
  String get rubbingCaption => '청동에서 뜬 탁본';

  @override
  String get pourInstruction => '물길을 돌린 다음, 가마를 여세요.';

  @override
  String get pourButton => '붓기';

  @override
  String get pourSpilt => '쇳물이 모래로 흘러나간다. 가마를 다시 닫는다.';

  @override
  String get pourShort => '흘리지는 않았지만, 빈 주입구가 있다.';

  @override
  String get resonanceInstruction => '당목을 뒤로 당겼다 놓으세요. 아래 명동을 파거나 메우세요.';

  @override
  String get resonanceDeeper => '더 깊게';

  @override
  String get resonanceShallower => '더 얕게';

  @override
  String get resonanceWeak => '너무 약하다. 당목이 청동에 거의 닿지 않는다.';

  @override
  String get resonanceShort => '울림이 표시에 닿기 전에 사라진다.';

  @override
  String get beatInstruction => '종의 아랫부분을 치세요. 맥놀이가 가장 깊은 곳을 찾아 표시하세요.';

  @override
  String get beatMark => '이곳에 표시';

  @override
  String get beatWrong => '여기가 아니다. 더 깊게 울리는 곳이 있다.';
}
