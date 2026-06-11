// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'リポジトリを検索...';

  @override
  String get myRepositories => 'マイリポジトリ';

  @override
  String get settings => '設定';

  @override
  String get selectOrder => '順序';

  @override
  String get sortLastUpdated => '更新順';

  @override
  String get sortName => '名前順';

  @override
  String get sortStars => 'スター数順';

  @override
  String get settingsTitle => '詳細設定';

  @override
  String get languageSettings => '言語設定';

  @override
  String get displayLanguage => '表示言語 / Display Language';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get powerPerformance => '省電力・パフォーマンス';

  @override
  String get lowSpecMode => '省電力・低スペック優先モード';

  @override
  String get lowSpecModeDesc =>
      '端末への負荷やバッテリー消費を抑えるため、極上演出やシマー効果をすべてオフにし、フラットUIに切り替えます。';

  @override
  String get springAnimation => '弾むスプリング物理アニメーション';

  @override
  String get springAnimationDesc => 'ボタンタップ時に弾む物理フィードバック演出を有効にします。';

  @override
  String get shimmerLoading => 'シマー（波打つ光）ローディング';

  @override
  String get shimmerLoadingDesc => 'データ読み込み中にキラキラと光るスケルトン画面を表示します。';

  @override
  String get listEntranceAnimation => 'リスト出現アニメーション (フェード/スライド)';

  @override
  String get listEntranceAnimationDesc =>
      'リポジトリ一覧やワークフロー詳細の表示時に、ふわっと浮き上がるように出現させます。';

  @override
  String get hapticsTouch => 'ハプティクス（指先触感）';

  @override
  String get hapticsFeedback => 'ハプティクスフィードバック';

  @override
  String get hapticsFeedbackDesc => 'ボタンタップや設定切り替え時に、微小な振動を返して物理的な手応えを感じさせます。';

  @override
  String get advancedTuning => '高度な微調整';

  @override
  String get advancedTuningDesc => '各演出の詳細パラメータを調整します。';

  @override
  String get notificationsUpdates => '通知とアップデート';

  @override
  String get updateCheckNotify => 'アプデチェック通知';

  @override
  String get updateCheckNotifyDesc =>
      'アプリ起動時にGitHubの最新リリース情報を自動でチェックし、アップデートがある場合に通知します。';

  @override
  String get githubIntegration => 'GitHub 連携';

  @override
  String get addNewAccount => '新しいアカウントを追加';

  @override
  String get addNewAccountDesc =>
      '別のGitHubアカウントを接続します。\\n※ブラウザ側で追加したいアカウントに事前ログインしておくとスムーズです。';

  @override
  String get manageAccounts => 'アカウントを追加・管理';

  @override
  String get manageAccountsDesc =>
      'GitHub Appを新しいOrganizationや個人アカウントにインストール・管理します。';

  @override
  String get dangerZone => '危険ゾーン (Danger Zone)';

  @override
  String get aboutApp => 'このアプリについて';

  @override
  String get accessibilitySupport => 'アクセシビリティ対応';

  @override
  String get accessibilitySupportDesc =>
      'WCAG 2.2、Apple HIG Accessibility、およびAndroid Build Accessible Apps ガイドラインに準拠して設計されています。';

  @override
  String get springScaleFactor => 'タップ時の縮小率';

  @override
  String get springScaleFactorDisabled => 'タップ時の縮小率 (上のスイッチを有効にすると調整可能)';

  @override
  String get shimmerSpeed => 'シマーアニメーション速度';

  @override
  String get shimmerSpeedDisabled => 'シマーアニメーション速度 (上のスイッチを有効にすると調整可能)';

  @override
  String get vibrationStrength => 'バイブレーション強度';

  @override
  String get vibrationStrengthDisabled => 'バイブレーション強度 (上のスイッチを有効にすると調整可能)';

  @override
  String get hapticLight => 'Light (繊細)';

  @override
  String get hapticMedium => 'Medium (通常)';

  @override
  String get hapticHeavy => 'Heavy (強力)';

  @override
  String get hapticSelection => 'Selection (クリック感)';

  @override
  String get guestModeActive => 'ゲストモードで利用中';

  @override
  String get guestModeDesc => 'GitHubアカウントと連携していません (パブリック情報のみ検索可能です)';

  @override
  String get noAccountRegistered => 'アカウントが登録されていません';

  @override
  String get currentlyActive => '現在使用中 (アクティブ)';

  @override
  String get tapToSwitch => 'タップして切り替え';

  @override
  String get confirmDisconnectAllTitle => 'すべてのアカウントを解除しますか？';

  @override
  String get confirmDisconnectTitle => 'アカウントの接続を解除しますか？';

  @override
  String get confirmDisconnectAllDesc => 'すべてのGitHubアカウントとの連携を解除し、完全にログアウトします。';

  @override
  String confirmDisconnectDesc(String username) {
    return '現在のアカウント (@$username) との連携を解除します。';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get disconnect => '解除';

  @override
  String get endGuestMode => 'ゲストモードを終了してログイン';

  @override
  String get endGuestModeDesc => 'ログイン画面へ戻り、GitHubアカウントと連携します。';

  @override
  String get disconnectCurrent => '現在のアカウントの接続解除';

  @override
  String get disconnectCurrentDesc => '選択中のアカウントのみ、このデバイスから接続を解除します。';

  @override
  String get logoutAll => 'すべてのアカウントを解除してログアウト';

  @override
  String get logoutAllDesc => '登録されている全てのアカウント情報をデバイスから削除します。';

  @override
  String get updateInfoTitle => 'アップデートのご案内';

  @override
  String newVersionAvailable(String version) {
    return '新しいバージョン $version が利用可能です！';
  }

  @override
  String currentVersion(String version) {
    return '現在のバージョン: $version';
  }

  @override
  String get releaseNotes => 'リリースノート:';

  @override
  String get releaseNotesFallback => 'バグ修正とパフォーマンスの向上。';

  @override
  String get later => '後で';

  @override
  String get update => 'アップデート';

  @override
  String get themeToggle => 'テーマ切り替え';

  @override
  String get searchHintText => '検索したいリポジトリ名を入力してください';

  @override
  String get repositories => 'リポジトリ';

  @override
  String get sortOrderTooltip => '並び替え';

  @override
  String get sortLastCiRun => '最後のCI/CD実行順';

  @override
  String get noRepositoriesFound => 'リポジトリが見つかりません';

  @override
  String errorOccurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get filter => 'フィルター';

  @override
  String get filterConditions => 'フィルター条件';

  @override
  String get reset => 'リセット';

  @override
  String get repositoryType => 'リポジトリタイプ';

  @override
  String get ownerType => 'オーナータイプ';

  @override
  String get account => 'アカウント';

  @override
  String get all => 'すべて';

  @override
  String get personal => '個人';

  @override
  String get organization => '組織 (Org)';

  @override
  String get applyFilter => 'フィルターを適用';

  @override
  String get authPageOpenError => '認証ページを開くことができませんでした。';

  @override
  String authPageError(String error) {
    return '認証ページを開く際にエラーが発生しました: $error';
  }

  @override
  String get invalidTokenError =>
      'トークンが無効です。正しいPersonal Access Tokenを入力してください。';

  @override
  String get appSubtitle => 'GitHub CI/CDモニタリングアプリ';

  @override
  String get connectWithGithub => 'GitHub Appで連携する';

  @override
  String get connectWithGithubDesc => 'GitHub App を使用して安全かつ迅速に連携できます。';

  @override
  String get skipGuestMode => 'ログインせずにスキップ (ゲストモード)';

  @override
  String get connectWithPat => 'または Personal Access Token で接続';

  @override
  String get enterToken => 'トークンを入力してください';

  @override
  String get connectWithPatBtn => 'PATで接続する';

  @override
  String get generateTokenOnGithub => 'GitHubでトークンを発行する';

  @override
  String get whatIsPat => 'Personal Access Tokenとは';

  @override
  String get patStep1 =>
      'GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => '「Generate new token (classic)」をクリック';

  @override
  String get patStep3 => 'スコープ: repo, read:user, workflow にチェックを入れる';

  @override
  String get patStep4 => '生成されたトークン（ghp_...）を入力欄に入力します。';

  @override
  String get sortBestMatch => 'ベストマッチ (関連度順)';

  @override
  String get searchTypeRepos => 'リポジトリ';

  @override
  String get searchTypeUsers => 'ユーザー & 組織';

  @override
  String get userProfile => 'ユーザー情報';

  @override
  String get searchUsersHint => 'ユーザー名または組織名を入力して検索してください';
}
