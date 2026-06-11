// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => '搜索仓库...';

  @override
  String get myRepositories => '我的仓库';

  @override
  String get settings => '设置';

  @override
  String get selectOrder => '顺序';

  @override
  String get sortLastUpdated => '更新顺序';

  @override
  String get sortName => '名称顺序';

  @override
  String get sortStars => '星标数顺序';

  @override
  String get settingsTitle => '高级设置';

  @override
  String get languageSettings => '语言设置';

  @override
  String get displayLanguage => '显示语言';

  @override
  String get systemDefault => '系统默认';

  @override
  String get powerPerformance => '省电与性能';

  @override
  String get lowSpecMode => '省电及低配置优先模式';

  @override
  String get lowSpecModeDesc =>
      '关闭所有高级动画和渐变光晕（Shimmer）效果，并切换到扁平 UI，以减少电池消耗和设备负载。';

  @override
  String get springAnimation => '弹性物理动画';

  @override
  String get springAnimationDesc => '启用按钮点击时的弹性物理反馈效果。';

  @override
  String get shimmerLoading => '渐变光晕加载';

  @override
  String get shimmerLoadingDesc => '在加载数据时显示闪烁的骨架屏。';

  @override
  String get listEntranceAnimation => '列表出现动画 (淡入/滑入)';

  @override
  String get listEntranceAnimationDesc => '在加载时，使列表项以淡入和滑入的动画效果显现。';

  @override
  String get hapticsTouch => '触觉反馈';

  @override
  String get hapticsFeedback => '触觉反馈';

  @override
  String get hapticsFeedbackDesc => '在交互时提供细微的震动反馈，体验物理手感。';

  @override
  String get advancedTuning => '高级微调';

  @override
  String get advancedTuningDesc => '微调动画的各个高级参数。';

  @override
  String get notificationsUpdates => '通知与更新';

  @override
  String get updateCheckNotify => '更新检查通知';

  @override
  String get updateCheckNotifyDesc =>
      '在启动时自动检查 GitHub 上的最新 Release 版本，并在有可用更新时发送通知。';

  @override
  String get githubIntegration => 'GitHub 关联';

  @override
  String get addNewAccount => '添加新账号';

  @override
  String get addNewAccountDesc =>
      '连接另一个 GitHub 账号。\\n* 如果您已在浏览器中预先登录了要添加的账号，过程会更顺畅。';

  @override
  String get manageAccounts => '添加与管理账号';

  @override
  String get manageAccountsDesc => '在新组织或个人账号中安装和管理 GitHub App。';

  @override
  String get dangerZone => '危险区域 (Danger Zone)';

  @override
  String get aboutApp => '关于此应用';

  @override
  String get accessibilitySupport => '无障碍支持';

  @override
  String get accessibilitySupportDesc =>
      '设计符合 WCAG 2.2、Apple HIG 无障碍指南以及 Android 编写无障碍应用指南。';

  @override
  String get springScaleFactor => '点击时的缩放比例';

  @override
  String get springScaleFactorDisabled => '点击时的缩放比例 (启用上方开关后可调节)';

  @override
  String get shimmerSpeed => '渐变光晕动画速度';

  @override
  String get shimmerSpeedDisabled => '渐变光晕动画速度 (启用上方开关后可调节)';

  @override
  String get vibrationStrength => '振动强度';

  @override
  String get vibrationStrengthDisabled => '振动强度 (启用上方开关后可调节)';

  @override
  String get hapticLight => 'Light (细微)';

  @override
  String get hapticMedium => 'Medium (默认)';

  @override
  String get hapticHeavy => 'Heavy (强劲)';

  @override
  String get hapticSelection => 'Selection (点击感)';

  @override
  String get guestModeActive => '正在以游客模式使用';

  @override
  String get guestModeDesc => '未与 GitHub 账号关联 (仅可搜索公开信息)';

  @override
  String get noAccountRegistered => '未注册账号';

  @override
  String get currentlyActive => '当前使用中 (活跃)';

  @override
  String get tapToSwitch => '点击切换';

  @override
  String get confirmDisconnectAllTitle => '是否断开所有账号的连接？';

  @override
  String get confirmDisconnectTitle => '是否断开账号连接？';

  @override
  String get confirmDisconnectAllDesc => '将断开与所有 GitHub 账号的关联并完全退出登录。';

  @override
  String confirmDisconnectDesc(String username) {
    return '断开当前账号 (@$username) 的关联。';
  }

  @override
  String get cancel => '取消';

  @override
  String get disconnect => '断开连接';

  @override
  String get endGuestMode => '退出游客模式并登录';

  @override
  String get endGuestModeDesc => '返回登录界面以关联您的 GitHub 账号。';

  @override
  String get disconnectCurrent => '断开当前账号的连接';

  @override
  String get disconnectCurrentDesc => '仅在此设备上断开所选账号的连接。';

  @override
  String get logoutAll => '断开所有账号并退出登录';

  @override
  String get logoutAllDesc => '从设备中删除所有已保存的账号信息。';

  @override
  String get updateInfoTitle => '更新提示';

  @override
  String newVersionAvailable(String version) {
    return '新版本 $version 已可用！';
  }

  @override
  String currentVersion(String version) {
    return '当前版本: $version';
  }

  @override
  String get releaseNotes => '更新日志:';

  @override
  String get releaseNotesFallback => 'Bug 修复和性能提升。';

  @override
  String get later => '稍后';

  @override
  String get update => '更新';

  @override
  String get themeToggle => '切换主题';

  @override
  String get searchHintText => '请输入您要搜索的仓库名称';

  @override
  String get repositories => '仓库';

  @override
  String get sortOrderTooltip => '排序';

  @override
  String get sortLastCiRun => '最近一次 CI/CD 运行';

  @override
  String get noRepositoriesFound => '未找到仓库';

  @override
  String errorOccurred(String error) {
    return '发生错误: $error';
  }

  @override
  String get filter => '筛选';

  @override
  String get filterConditions => '筛选条件';

  @override
  String get reset => '重置';

  @override
  String get repositoryType => '仓库类型';

  @override
  String get ownerType => '所有者类型';

  @override
  String get account => '账号';

  @override
  String get all => '全部';

  @override
  String get personal => '个人';

  @override
  String get organization => '组织 (Org)';

  @override
  String get applyFilter => '应用筛选';

  @override
  String get authPageOpenError => '无法打开授权页面。';

  @override
  String authPageError(String error) {
    return '打开授权页面时发生错误: $error';
  }

  @override
  String get invalidTokenError => '凭证 (Token) 无效。请输入正确的 Personal Access Token。';

  @override
  String get appSubtitle => 'GitHub CI/CD 监控应用';

  @override
  String get connectWithGithub => '通过 GitHub App 关联';

  @override
  String get connectWithGithubDesc => '使用 GitHub App 安全且快速地进行关联。';

  @override
  String get skipGuestMode => '跳过登录 (游客模式)';

  @override
  String get connectWithPat => '或者通过 Personal Access Token 连接';

  @override
  String get enterToken => '请输入您的 Token';

  @override
  String get connectWithPatBtn => '使用 PAT 连接';

  @override
  String get generateTokenOnGithub => '在 GitHub 上生成 Token';

  @override
  String get whatIsPat => '什么是 Personal Access Token？';

  @override
  String get patStep1 =>
      'GitHub 设置 → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => '点击 \"Generate new token (classic)\"';

  @override
  String get patStep3 => '勾选 scopes: repo, read:user, workflow';

  @override
  String get patStep4 => '在输入框中输入生成的 Token (ghp_...)';
}
