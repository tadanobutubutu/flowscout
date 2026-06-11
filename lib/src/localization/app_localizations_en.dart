// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'Search repositories...';

  @override
  String get myRepositories => 'My Repositories';

  @override
  String get settings => 'Settings';

  @override
  String get selectOrder => 'Order';

  @override
  String get sortLastUpdated => 'Last updated';

  @override
  String get sortName => 'Name';

  @override
  String get sortStars => 'Stars';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get displayLanguage => 'Display Language';

  @override
  String get systemDefault => 'System Default';

  @override
  String get powerPerformance => 'Power & Performance';

  @override
  String get lowSpecMode => 'Power Saving & Low Spec Mode';

  @override
  String get lowSpecModeDesc =>
      'Turns off premium animations and shimmer effects, switching to a flat UI to reduce battery consumption and device load.';

  @override
  String get springAnimation => 'Spring Physics Animation';

  @override
  String get springAnimationDesc =>
      'Enable spring physics feedback on button tap.';

  @override
  String get shimmerLoading => 'Shimmer Loading';

  @override
  String get shimmerLoadingDesc =>
      'Show a shimmering skeleton screen while loading data.';

  @override
  String get listEntranceAnimation => 'List Entrance Animation (Fade/Slide)';

  @override
  String get listEntranceAnimationDesc =>
      'Animate list items fading and sliding in when loaded.';

  @override
  String get hapticsTouch => 'Haptic Feedback';

  @override
  String get hapticsFeedback => 'Haptic Feedback';

  @override
  String get hapticsFeedbackDesc =>
      'Provide subtle vibrations on interactions to feel tactile feedback.';

  @override
  String get advancedTuning => 'Advanced Tuning';

  @override
  String get advancedTuningDesc =>
      'Tune advanced parameters of the animations.';

  @override
  String get notificationsUpdates => 'Notifications & Updates';

  @override
  String get updateCheckNotify => 'Update Notifications';

  @override
  String get updateCheckNotifyDesc =>
      'Check for the latest Flowscout releases on startup and notify if updates are available.';

  @override
  String get githubIntegration => 'GitHub Integration';

  @override
  String get addNewAccount => 'Add New Account';

  @override
  String get addNewAccountDesc =>
      'Connect another GitHub account.\\n* It\'s smoother if you are already logged in to that account in your browser.';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String get manageAccountsDesc =>
      'Install and manage the GitHub App on new organizations or personal accounts.';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get aboutApp => 'About This App';

  @override
  String get accessibilitySupport => 'Accessibility Support';

  @override
  String get accessibilitySupportDesc =>
      'Designed in compliance with WCAG 2.2, Apple HIG Accessibility, and Android Build Accessible Apps guidelines.';

  @override
  String get springScaleFactor => 'Tap Scale Factor';

  @override
  String get springScaleFactorDisabled =>
      'Tap Scale Factor (Enable switch above to adjust)';

  @override
  String get shimmerSpeed => 'Shimmer Speed';

  @override
  String get shimmerSpeedDisabled =>
      'Shimmer Speed (Enable switch above to adjust)';

  @override
  String get vibrationStrength => 'Vibration Strength';

  @override
  String get vibrationStrengthDisabled =>
      'Vibration Strength (Enable switch above to adjust)';

  @override
  String get hapticLight => 'Light (Subtle)';

  @override
  String get hapticMedium => 'Medium (Default)';

  @override
  String get hapticHeavy => 'Heavy (Strong)';

  @override
  String get hapticSelection => 'Selection (Click effect)';

  @override
  String get guestModeActive => 'Using Guest Mode';

  @override
  String get guestModeDesc =>
      'Not connected to a GitHub account (public info search only).';

  @override
  String get noAccountRegistered => 'No account registered';

  @override
  String get currentlyActive => 'Active';

  @override
  String get tapToSwitch => 'Tap to switch';

  @override
  String get confirmDisconnectAllTitle => 'Disconnect all accounts?';

  @override
  String get confirmDisconnectTitle => 'Disconnect account?';

  @override
  String get confirmDisconnectAllDesc =>
      'All GitHub accounts will be disconnected and you will be logged out.';

  @override
  String confirmDisconnectDesc(String username) {
    return 'Disconnect the current account (@$username).';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get endGuestMode => 'Exit Guest Mode & Login';

  @override
  String get endGuestModeDesc =>
      'Go back to the login screen to link your your GitHub account.';

  @override
  String get disconnectCurrent => 'Disconnect Current Account';

  @override
  String get disconnectCurrentDesc =>
      'Disconnect only the selected account from this device.';

  @override
  String get logoutAll => 'Disconnect All & Logout';

  @override
  String get logoutAllDesc =>
      'Remove all registered account information from the device.';

  @override
  String get updateInfoTitle => 'Update Notice';

  @override
  String newVersionAvailable(String version) {
    return 'New version $version is available!';
  }

  @override
  String currentVersion(String version) {
    return 'Current version: $version';
  }

  @override
  String get releaseNotes => 'Release Notes:';

  @override
  String get releaseNotesFallback => 'Bug fixes and performance improvements.';

  @override
  String get later => 'Later';

  @override
  String get update => 'Update';

  @override
  String get themeToggle => 'Toggle Theme';

  @override
  String get searchHintText => 'Enter the repository name you want to search';

  @override
  String get repositories => 'Repositories';

  @override
  String get sortOrderTooltip => 'Sort';

  @override
  String get sortLastCiRun => 'Last CI/CD Run';

  @override
  String get noRepositoriesFound => 'No repositories found';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get filter => 'Filter';

  @override
  String get filterConditions => 'Filter Conditions';

  @override
  String get reset => 'Reset';

  @override
  String get repositoryType => 'Repository Type';

  @override
  String get ownerType => 'Owner Type';

  @override
  String get account => 'Account';

  @override
  String get all => 'All';

  @override
  String get personal => 'Personal';

  @override
  String get organization => 'Organization';

  @override
  String get applyFilter => 'Apply Filters';

  @override
  String get authPageOpenError => 'Could not open the authentication page.';

  @override
  String authPageError(String error) {
    return 'An error occurred while opening the authentication page: $error';
  }

  @override
  String get invalidTokenError =>
      'Invalid token. Please enter a valid Personal Access Token.';

  @override
  String get appSubtitle => 'GitHub CI/CD Monitoring App';

  @override
  String get connectWithGithub => 'Connect with GitHub App';

  @override
  String get connectWithGithubDesc =>
      'Connect securely and quickly using the GitHub App.';

  @override
  String get skipGuestMode => 'Skip and use Guest Mode';

  @override
  String get connectWithPat => 'Or connect with Personal Access Token';

  @override
  String get enterToken => 'Please enter your token';

  @override
  String get connectWithPatBtn => 'Connect with PAT';

  @override
  String get generateTokenOnGithub => 'Generate Token on GitHub';

  @override
  String get whatIsPat => 'What is a Personal Access Token?';

  @override
  String get patStep1 =>
      'GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => 'Click \"Generate new token (classic)\"';

  @override
  String get patStep3 => 'Select scopes: repo, read:user, workflow';

  @override
  String get patStep4 => 'Enter the generated token (ghp_...) in the field.';

  @override
  String get sortBestMatch => 'Best Match';

  @override
  String get searchTypeRepos => 'Repositories';

  @override
  String get searchTypeUsers => 'Users & Orgs';

  @override
  String get userProfile => 'Profile';
}
