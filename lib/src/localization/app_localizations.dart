import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flowscout'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search repositories...'**
  String get searchHint;

  /// No description provided for @myRepositories.
  ///
  /// In en, this message translates to:
  /// **'My Repositories'**
  String get myRepositories;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @selectOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get selectOrder;

  /// No description provided for @sortLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get sortLastUpdated;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortStars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get sortStars;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get displayLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @powerPerformance.
  ///
  /// In en, this message translates to:
  /// **'Power & Performance'**
  String get powerPerformance;

  /// No description provided for @lowSpecMode.
  ///
  /// In en, this message translates to:
  /// **'Power Saving & Low Spec Mode'**
  String get lowSpecMode;

  /// No description provided for @lowSpecModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Turns off premium animations and shimmer effects, switching to a flat UI to reduce battery consumption and device load.'**
  String get lowSpecModeDesc;

  /// No description provided for @springAnimation.
  ///
  /// In en, this message translates to:
  /// **'Spring Physics Animation'**
  String get springAnimation;

  /// No description provided for @springAnimationDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable spring physics feedback on button tap.'**
  String get springAnimationDesc;

  /// No description provided for @shimmerLoading.
  ///
  /// In en, this message translates to:
  /// **'Shimmer Loading'**
  String get shimmerLoading;

  /// No description provided for @shimmerLoadingDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a shimmering skeleton screen while loading data.'**
  String get shimmerLoadingDesc;

  /// No description provided for @listEntranceAnimation.
  ///
  /// In en, this message translates to:
  /// **'List Entrance Animation (Fade/Slide)'**
  String get listEntranceAnimation;

  /// No description provided for @listEntranceAnimationDesc.
  ///
  /// In en, this message translates to:
  /// **'Animate list items fading and sliding in when loaded.'**
  String get listEntranceAnimationDesc;

  /// No description provided for @hapticsTouch.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticsTouch;

  /// No description provided for @hapticsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticsFeedback;

  /// No description provided for @hapticsFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Provide subtle vibrations on interactions to feel tactile feedback.'**
  String get hapticsFeedbackDesc;

  /// No description provided for @advancedTuning.
  ///
  /// In en, this message translates to:
  /// **'Advanced Tuning'**
  String get advancedTuning;

  /// No description provided for @advancedTuningDesc.
  ///
  /// In en, this message translates to:
  /// **'Tune advanced parameters of the animations.'**
  String get advancedTuningDesc;

  /// No description provided for @notificationsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Notifications & Updates'**
  String get notificationsUpdates;

  /// No description provided for @updateCheckNotify.
  ///
  /// In en, this message translates to:
  /// **'Update Notifications'**
  String get updateCheckNotify;

  /// No description provided for @updateCheckNotifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Check for the latest Flowscout releases on startup and notify if updates are available.'**
  String get updateCheckNotifyDesc;

  /// No description provided for @githubIntegration.
  ///
  /// In en, this message translates to:
  /// **'GitHub Integration'**
  String get githubIntegration;

  /// No description provided for @addNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccount;

  /// No description provided for @addNewAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect another GitHub account.\\n* It\'s smoother if you are already logged in to that account in your browser.'**
  String get addNewAccountDesc;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// No description provided for @manageAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Install and manage the GitHub App on new organizations or personal accounts.'**
  String get manageAccountsDesc;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About This App'**
  String get aboutApp;

  /// No description provided for @accessibilitySupport.
  ///
  /// In en, this message translates to:
  /// **'Accessibility Support'**
  String get accessibilitySupport;

  /// No description provided for @accessibilitySupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Designed in compliance with WCAG 2.2, Apple HIG Accessibility, and Android Build Accessible Apps guidelines.'**
  String get accessibilitySupportDesc;

  /// No description provided for @springScaleFactor.
  ///
  /// In en, this message translates to:
  /// **'Tap Scale Factor'**
  String get springScaleFactor;

  /// No description provided for @springScaleFactorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Tap Scale Factor (Enable switch above to adjust)'**
  String get springScaleFactorDisabled;

  /// No description provided for @shimmerSpeed.
  ///
  /// In en, this message translates to:
  /// **'Shimmer Speed'**
  String get shimmerSpeed;

  /// No description provided for @shimmerSpeedDisabled.
  ///
  /// In en, this message translates to:
  /// **'Shimmer Speed (Enable switch above to adjust)'**
  String get shimmerSpeedDisabled;

  /// No description provided for @vibrationStrength.
  ///
  /// In en, this message translates to:
  /// **'Vibration Strength'**
  String get vibrationStrength;

  /// No description provided for @vibrationStrengthDisabled.
  ///
  /// In en, this message translates to:
  /// **'Vibration Strength (Enable switch above to adjust)'**
  String get vibrationStrengthDisabled;

  /// No description provided for @hapticLight.
  ///
  /// In en, this message translates to:
  /// **'Light (Subtle)'**
  String get hapticLight;

  /// No description provided for @hapticMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (Default)'**
  String get hapticMedium;

  /// No description provided for @hapticHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy (Strong)'**
  String get hapticHeavy;

  /// No description provided for @hapticSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection (Click effect)'**
  String get hapticSelection;

  /// No description provided for @guestModeActive.
  ///
  /// In en, this message translates to:
  /// **'Using Guest Mode'**
  String get guestModeActive;

  /// No description provided for @guestModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Not connected to a GitHub account (public info search only).'**
  String get guestModeDesc;

  /// No description provided for @noAccountRegistered.
  ///
  /// In en, this message translates to:
  /// **'No account registered'**
  String get noAccountRegistered;

  /// No description provided for @currentlyActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get currentlyActive;

  /// No description provided for @tapToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch'**
  String get tapToSwitch;

  /// No description provided for @confirmDisconnectAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect all accounts?'**
  String get confirmDisconnectAllTitle;

  /// No description provided for @confirmDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect account?'**
  String get confirmDisconnectTitle;

  /// No description provided for @confirmDisconnectAllDesc.
  ///
  /// In en, this message translates to:
  /// **'All GitHub accounts will be disconnected and you will be logged out.'**
  String get confirmDisconnectAllDesc;

  /// No description provided for @confirmDisconnectDesc.
  ///
  /// In en, this message translates to:
  /// **'Disconnect the current account (@{username}).'**
  String confirmDisconnectDesc(String username);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @endGuestMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Guest Mode & Login'**
  String get endGuestMode;

  /// No description provided for @endGuestModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Go back to the login screen to link your your GitHub account.'**
  String get endGuestModeDesc;

  /// No description provided for @disconnectCurrent.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Current Account'**
  String get disconnectCurrent;

  /// No description provided for @disconnectCurrentDesc.
  ///
  /// In en, this message translates to:
  /// **'Disconnect only the selected account from this device.'**
  String get disconnectCurrentDesc;

  /// No description provided for @logoutAll.
  ///
  /// In en, this message translates to:
  /// **'Disconnect All & Logout'**
  String get logoutAll;

  /// No description provided for @logoutAllDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove all registered account information from the device.'**
  String get logoutAllDesc;

  /// No description provided for @updateInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Notice'**
  String get updateInfoTitle;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version {version} is available!'**
  String newVersionAvailable(String version);

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String currentVersion(String version);

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes:'**
  String get releaseNotes;

  /// No description provided for @releaseNotesFallback.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes and performance improvements.'**
  String get releaseNotesFallback;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @themeToggle.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get themeToggle;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter the repository name you want to search'**
  String get searchHintText;

  /// No description provided for @repositories.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get repositories;

  /// No description provided for @sortOrderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortOrderTooltip;

  /// No description provided for @sortLastCiRun.
  ///
  /// In en, this message translates to:
  /// **'Last CI/CD Run'**
  String get sortLastCiRun;

  /// No description provided for @noRepositoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No repositories found'**
  String get noRepositoriesFound;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(String error);

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterConditions.
  ///
  /// In en, this message translates to:
  /// **'Filter Conditions'**
  String get filterConditions;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @repositoryType.
  ///
  /// In en, this message translates to:
  /// **'Repository Type'**
  String get repositoryType;

  /// No description provided for @ownerType.
  ///
  /// In en, this message translates to:
  /// **'Owner Type'**
  String get ownerType;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilter;

  /// No description provided for @authPageOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the authentication page.'**
  String get authPageOpenError;

  /// No description provided for @authPageError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while opening the authentication page: {error}'**
  String authPageError(String error);

  /// No description provided for @invalidTokenError.
  ///
  /// In en, this message translates to:
  /// **'Invalid token. Please enter a valid Personal Access Token.'**
  String get invalidTokenError;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GitHub CI/CD Monitoring App'**
  String get appSubtitle;

  /// No description provided for @connectWithGithub.
  ///
  /// In en, this message translates to:
  /// **'Connect with GitHub App'**
  String get connectWithGithub;

  /// No description provided for @connectWithGithubDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect securely and quickly using the GitHub App.'**
  String get connectWithGithubDesc;

  /// No description provided for @skipGuestMode.
  ///
  /// In en, this message translates to:
  /// **'Skip and use Guest Mode'**
  String get skipGuestMode;

  /// No description provided for @connectWithPat.
  ///
  /// In en, this message translates to:
  /// **'Or connect with Personal Access Token'**
  String get connectWithPat;

  /// No description provided for @enterToken.
  ///
  /// In en, this message translates to:
  /// **'Please enter your token'**
  String get enterToken;

  /// No description provided for @connectWithPatBtn.
  ///
  /// In en, this message translates to:
  /// **'Connect with PAT'**
  String get connectWithPatBtn;

  /// No description provided for @generateTokenOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Generate Token on GitHub'**
  String get generateTokenOnGithub;

  /// No description provided for @whatIsPat.
  ///
  /// In en, this message translates to:
  /// **'What is a Personal Access Token?'**
  String get whatIsPat;

  /// No description provided for @patStep1.
  ///
  /// In en, this message translates to:
  /// **'GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)'**
  String get patStep1;

  /// No description provided for @patStep2.
  ///
  /// In en, this message translates to:
  /// **'Click \"Generate new token (classic)\"'**
  String get patStep2;

  /// No description provided for @patStep3.
  ///
  /// In en, this message translates to:
  /// **'Select scopes: repo, read:user, workflow'**
  String get patStep3;

  /// No description provided for @patStep4.
  ///
  /// In en, this message translates to:
  /// **'Enter the generated token (ghp_...) in the field.'**
  String get patStep4;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
