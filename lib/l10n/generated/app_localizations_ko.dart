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

  @override
  String get docketHeader => '런던 경찰청';

  @override
  String get docketSubheader => '범죄수사과';

  @override
  String get unwatchedInstruction => '눈을 돌렸다가 다시 보세요.';

  @override
  String get unwatchedFind => '선반에 새로운 것이 있다. 찾아보세요.';

  @override
  String get unwatchedWrong => '그건 원래 있던 것이다.';

  @override
  String get unwatchedLookAway => '눈 돌리기';

  @override
  String unwatchedProgress(int found, int total) {
    return '새 서류철: $found / $total';
  }

  @override
  String get composeInstruction =>
      '활자 상자에서 그녀의 이름을 조판하세요. 활자는 거울처럼 거꾸로 새겨져 있다.';

  @override
  String get composeTakeOut => '빼기';

  @override
  String get composeWrong => '교정쇄 어딘가가 틀렸다.';

  @override
  String get strandInstruction => '마디를 눌러 측정하자. 가닥마다 가장 높은 값을 찾아 표시하자.';

  @override
  String strandBudget(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '남은 측정 $count번',
      zero: '남은 측정 없음',
    );
    return '$_temp0';
  }

  @override
  String get strandMark => '최고로 표시';

  @override
  String get strandWrong => '가장 높지 않다. 옆 마디가 더 높을지도 모른다.';

  @override
  String get strandNewSample => '새 시료';

  @override
  String get strandOut => '이 시료에 쓸 원자로 시간이 다 됐다. 새 시료를 쓰자.';

  @override
  String get strandCurveQuestion => '비소는 머리카락을 따라 어떻게 분포하는가?';

  @override
  String get strandSteady => '여러 해에 걸쳐 고르게';

  @override
  String get strandPeak => '날카로운 봉우리들';

  @override
  String get strandCurveWrong => '가장 높은 값 주변을 다시 보자.';

  @override
  String get scanInstruction => '탐침을 옷 위로 끌자. 바늘이 빨간 칸에 들어가는 곳을 표시하자.';

  @override
  String get scanMark => '여기 표시';

  @override
  String get scanWrong => '여기서는 바늘이 거의 움직이지 않는다.';

  @override
  String get scanFaint => '바늘이 움직이지만 빨간 칸까지는 아니다. 이 옷감 너머로는 너무 약한가?';

  @override
  String get scanAgain => '이미 표시했다.';

  @override
  String scanFound(String place) {
    return '표시함: $place';
  }

  @override
  String scanProgress(int found, int total) {
    return '표시한 곳: $found/$total';
  }

  @override
  String get vermilionCaption => '붉은 먹으로';

  @override
  String get quireInstruction =>
      '종이 하나를 누르고 다른 종이를 누르면 접장 속에서 자리가 바뀐다. 종이를 뒤집으면 두 장이 서로 바뀐다. 이음말이 모두 제 쪽을 만나야 한다.';

  @override
  String get quireTurn => '뒤집기';

  @override
  String quireLinks(int count, int total) {
    return '이음말 $total개 중 $count개가 제 쪽을 만났다';
  }

  @override
  String get quirePicked => '다른 종이를 눌러 자리를 바꾸거나, 이 종이를 뒤집자.';

  @override
  String get dipInstruction => '갈대를 저장조 안으로 끌어내려 수면에 닿으면 놓고, 어떻게 떨어지는지 보자.';

  @override
  String get dipWhat => '갈대에서 무엇이 떨어지나?';

  @override
  String get dipWrong => '그렇게 떨어지지 않는다.';

  @override
  String dipLevel(int percent) {
    return '$percent%까지 차 있음';
  }

  @override
  String get dipStoresQuestion => '저장조마다 이름이 붙었다. 저장품은 바닥나고 있었을까, 가득했을까?';

  @override
  String get dipLow => '바닥나고 있었다';

  @override
  String get dipFull => '가득했다';

  @override
  String get dipStoresWrong => '저장조마다 얼마나 차 있는지 다시 보자.';

  @override
  String get colophonCaption => '여기서 책이 끝난다';

  @override
  String get coursesInstruction =>
      '떨어진 돌덩어리를 왼쪽부터 한 층씩 다시 쌓자. 아래층의 이음매 위에서 돌이 끝나면 안 된다.';

  @override
  String coursesCourse(int course, int total) {
    return '$total층 중 $course층';
  }

  @override
  String get coursesTooLong => '너무 길다. 틈을 넘어간다.';

  @override
  String get coursesJoint => '이음매 위에 이음매. 거기서 담이 갈라진다.';

  @override
  String get coursesTakeBack => '되돌리기';

  @override
  String get coursesBand => '갈매기무늬 띠. 판석을 누르면 반대로 기운다. 번갈아 기울 때까지.';

  @override
  String get identifyInstruction => '나무 조각을 보자. 무엇이 맞는가?';

  @override
  String identifyWrong(String name) {
    return '검색표가 닿은 곳: $name';
  }

  @override
  String get identifyBack => '길을 잘못 든 곳으로 돌아간다.';

  @override
  String get cartoucheCaption => '내륙의 새 지도';

  @override
  String get snowpitInstruction =>
      '층을 누른 다음 무언가를 밀어 넣자. 들어가는 것 중 가장 큰 것이 그 단단함이다.';

  @override
  String snowpitIn(String tool) {
    return '$tool: 들어간다';
  }

  @override
  String snowpitOut(String tool) {
    return '$tool: 들어가지 않는다';
  }

  @override
  String get snowpitMark => '약층으로 표시';

  @override
  String get snowpitUntested => '먼저 이 층과 그 위층의 단단함을 알아내자.';

  @override
  String get snowpitNotSofter => '위층보다 무르지 않다.';

  @override
  String get snowpitTap => '두드리기';

  @override
  String snowpitTaps(int count, String phase) {
    return '두드린 횟수: $count ($phase)';
  }

  @override
  String get snowpitWrist => '손목으로';

  @override
  String get snowpitElbow => '팔꿈치로';

  @override
  String get snowpitShoulder => '어깨로';

  @override
  String get snowpitColumn => '표시한 층 바로 아래까지 기둥을 잘라 냈다. 위에서 삽을 두드리자.';

  @override
  String get snowpitSpent => '서른 번을 두드려도 아무것도 부러지지 않았다. 약층은 더 깊다.';

  @override
  String get snowpitBrokeElsewhere => '다른 층, 더 위에서 부러졌다. 그 층을 표시하자.';

  @override
  String get toolFist => '주먹';

  @override
  String get toolFourFingers => '손가락 네 개';

  @override
  String get toolOneFinger => '손가락 하나';

  @override
  String get toolPencil => '연필';

  @override
  String get toolKnife => '칼';

  @override
  String get darkroomInstruction => '프레임을 고르자. 그 테스트 스트립에서 인화할 띠를 누르자.';

  @override
  String get darkroomLight => '너무 짧다. 잿빛으로 비었다. 인화지를 버렸다.';

  @override
  String get darkroomDark => '너무 길다. 눈이 잿빛이 되었다. 인화지를 버렸다.';

  @override
  String darkroomSeconds(String seconds) {
    return '$seconds초';
  }

  @override
  String get routebookCaption => '경로 수첩';
}
