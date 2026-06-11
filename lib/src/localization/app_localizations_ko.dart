// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => '저장소 검색...';

  @override
  String get myRepositories => '내 저장소';

  @override
  String get settings => '설정';

  @override
  String get selectOrder => '정렬 순서';

  @override
  String get sortLastUpdated => '최근 업데이트순';

  @override
  String get sortName => '이름순';

  @override
  String get sortStars => '스타순';

  @override
  String get settingsTitle => '상세 설정';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get displayLanguage => '표시 언어';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get powerPerformance => '절전 및 성능';

  @override
  String get lowSpecMode => '절전 및 저사양 모드';

  @override
  String get lowSpecModeDesc =>
      '배터리 소모와 기기 부하를 줄이기 위해 고급 애니메이션과 쉬머 효과를 끄고 플랫 UI로 전환합니다.';

  @override
  String get springAnimation => '스프링 물리 애니메이션';

  @override
  String get springAnimationDesc => '버튼 탭 시 스프링 물리 피드백을 활성화합니다.';

  @override
  String get shimmerLoading => '쉬머 로딩';

  @override
  String get shimmerLoadingDesc => '데이터를 불러오는 동안 쉬머 스켈레톤 화면을 표시합니다.';

  @override
  String get listEntranceAnimation => '리스트 등장 애니메이션 (페이드/슬라이드)';

  @override
  String get listEntranceAnimationDesc =>
      '데이터 로드 시 리스트 항목이 페이드인 및 슬라이드인하며 표시됩니다.';

  @override
  String get hapticsTouch => '햅틱 피드백';

  @override
  String get hapticsFeedback => '햅틱 피드백';

  @override
  String get hapticsFeedbackDesc => '상호작용 시 미세한 진동을 제공하여 물리적인 손맛을 느끼게 합니다.';

  @override
  String get advancedTuning => '고급 미세 조정';

  @override
  String get advancedTuningDesc => '애니메이션의 고급 매개변수를 조정합니다.';

  @override
  String get notificationsUpdates => '알림 및 업데이트';

  @override
  String get updateCheckNotify => '업데이트 알림';

  @override
  String get updateCheckNotifyDesc =>
      '시작 시 Flowscout의 최신 릴리스를 확인하고 업데이트가 있을 경우 알립니다.';

  @override
  String get githubIntegration => 'GitHub 연동';

  @override
  String get addNewAccount => '새 계정 추가';

  @override
  String get addNewAccountDesc =>
      '다른 GitHub 계정을 연결합니다.\\n* 브라우저에서 해당 계정으로 미리 로그인해 두면 원활하게 진행됩니다.';

  @override
  String get manageAccounts => '계정 관리';

  @override
  String get manageAccountsDesc => '새 조직 또는 개인 계정에 GitHub App을 설치하고 관리합니다.';

  @override
  String get dangerZone => '위험 구역';

  @override
  String get aboutApp => '이 앱 정보';

  @override
  String get accessibilitySupport => '접근성 지원';

  @override
  String get accessibilitySupportDesc =>
      'WCAG 2.2, Apple HIG Accessibility 및 Android Build Accessible Apps 가이드라인을 준수하여 설계되었습니다.';

  @override
  String get springScaleFactor => '탭 시 축소율';

  @override
  String get springScaleFactorDisabled => '탭 시 축소율 (위의 스위치를 활성화하면 조절 가능)';

  @override
  String get shimmerSpeed => '쉬머 애니메이션 속도';

  @override
  String get shimmerSpeedDisabled => '쉬머 애니메이션 속도 (위의 스위치를 활성화하면 조절 가능)';

  @override
  String get vibrationStrength => '진동 세기';

  @override
  String get vibrationStrengthDisabled => '진동 세기 (위의 스위치를 활성화하면 조절 가능)';

  @override
  String get hapticLight => 'Light (가볍게)';

  @override
  String get hapticMedium => 'Medium (보통)';

  @override
  String get hapticHeavy => 'Heavy (강하게)';

  @override
  String get hapticSelection => 'Selection (클릭감)';

  @override
  String get guestModeActive => '게스트 모드 사용 중';

  @override
  String get guestModeDesc => 'GitHub 계정과 연동되지 않음 (공개 정보만 검색 가능)';

  @override
  String get noAccountRegistered => '등록된 계정이 없습니다';

  @override
  String get currentlyActive => '활성화됨';

  @override
  String get tapToSwitch => '탭하여 전환';

  @override
  String get confirmDisconnectAllTitle => '모든 계정의 연결을 해제하시겠습니까?';

  @override
  String get confirmDisconnectTitle => '계정 연결을 해제하시겠습니까?';

  @override
  String get confirmDisconnectAllDesc => '모든 GitHub 계정의 연결이 해제되고 로그아웃됩니다.';

  @override
  String confirmDisconnectDesc(String username) {
    return '현재 계정(@$username)의 연결을 해제합니다.';
  }

  @override
  String get cancel => '취소';

  @override
  String get disconnect => '연결 해제';

  @override
  String get endGuestMode => '게스트 모드 종료 및 로그인';

  @override
  String get endGuestModeDesc => '로그인 화면으로 돌아가 GitHub 계정을 연동합니다.';

  @override
  String get disconnectCurrent => '현재 계정 연결 해제';

  @override
  String get disconnectCurrentDesc => '이 기기에서 선택한 계정만 연결을 해제합니다.';

  @override
  String get logoutAll => '모든 계정 연결 해제 및 로그아웃';

  @override
  String get logoutAllDesc => '기기에서 등록된 모든 계정 정보를 삭제합니다.';

  @override
  String get updateInfoTitle => '업데이트 안내';

  @override
  String newVersionAvailable(String version) {
    return '새로운 버전 $version을 사용할 수 있습니다!';
  }

  @override
  String currentVersion(String version) {
    return '현재 버전: $version';
  }

  @override
  String get releaseNotes => '릴리스 노트:';

  @override
  String get releaseNotesFallback => '버그 수정 및 성능 개선.';

  @override
  String get later => '나중에';

  @override
  String get update => '업데이트';

  @override
  String get themeToggle => '테마 전환';

  @override
  String get searchHintText => '검색할 저장소 이름을 입력하세요';

  @override
  String get repositories => '저장소';

  @override
  String get sortOrderTooltip => '정렬';

  @override
  String get sortLastCiRun => '마지막 CI/CD 실행순';

  @override
  String get noRepositoriesFound => '저장소를 찾을 수 없습니다';

  @override
  String errorOccurred(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get filter => '필터';

  @override
  String get filterConditions => '필터 조건';

  @override
  String get reset => '초기화';

  @override
  String get repositoryType => '저장소 유형';

  @override
  String get ownerType => '소유자 유형';

  @override
  String get account => '계정';

  @override
  String get all => '전체';

  @override
  String get personal => '개인';

  @override
  String get organization => '조직 (Org)';

  @override
  String get applyFilter => '필터 적용';

  @override
  String get authPageOpenError => '인증 페이지를 열 수 없습니다.';

  @override
  String authPageError(String error) {
    return '인증 페이지를 여는 동안 오류가 발생했습니다: $error';
  }

  @override
  String get invalidTokenError =>
      '토큰이 유효하지 않습니다. 올바른 Personal Access Token을 입력해 주세요.';

  @override
  String get appSubtitle => 'GitHub CI/CD 모니터링 앱';

  @override
  String get connectWithGithub => 'GitHub App으로 연동하기';

  @override
  String get connectWithGithubDesc => 'GitHub App을 사용하여 안전하고 신속하게 연동할 수 있습니다.';

  @override
  String get skipGuestMode => '로그인하지 않고 건너뛰기 (게스트 모드)';

  @override
  String get connectWithPat => '또는 Personal Access Token으로 연결';

  @override
  String get enterToken => '토큰을 입력해 주세요';

  @override
  String get connectWithPatBtn => 'PAT로 연결하기';

  @override
  String get generateTokenOnGithub => 'GitHub에서 토큰 생성하기';

  @override
  String get whatIsPat => 'Personal Access Token이란?';

  @override
  String get patStep1 =>
      'GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => '「Generate new token (classic)」 클릭';

  @override
  String get patStep3 => 'repo, read:user, workflow 스코프 체크';

  @override
  String get patStep4 => '생성된 토큰(ghp_...)을 입력란에 입력합니다.';

  @override
  String get sortBestMatch => '정확도순 (Best Match)';

  @override
  String get searchTypeRepos => '저장소';

  @override
  String get searchTypeUsers => '사용자 및 조직';

  @override
  String get userProfile => '프로필';
}
