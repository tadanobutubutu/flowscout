// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'Repositorys suchen...';

  @override
  String get myRepositories => 'Meine Repositorys';

  @override
  String get settings => 'Einstellungen';

  @override
  String get selectOrder => 'Reihenfolge';

  @override
  String get sortLastUpdated => 'Zuletzt aktualisiert';

  @override
  String get sortName => 'Name';

  @override
  String get sortStars => 'Sterne';

  @override
  String get settingsTitle => 'Erweiterte Einstellungen';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get displayLanguage => 'Anzeigesprache';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get powerPerformance => 'Leistung & Energie';

  @override
  String get lowSpecMode => 'Energiespar- & niedriger Spezifikationsmodus';

  @override
  String get lowSpecModeDesc =>
      'Schaltet Premium-Animationen und Shimmer-Effekte aus und wechselt zu einer flachen Benutzeroberfläche, um den Batterieverbrauch und die Geräteauslastung zu reduzieren.';

  @override
  String get springAnimation => 'Federphysik-Animation';

  @override
  String get springAnimationDesc =>
      'Aktiviert Federphysik-Feedback beim Tippen auf Schaltflächen.';

  @override
  String get shimmerLoading => 'Shimmer-Ladeeffekt';

  @override
  String get shimmerLoadingDesc =>
      'Zeigt während des Ladens von Daten einen schimmernden Platzhalter-Bildschirm an.';

  @override
  String get listEntranceAnimation =>
      'Animation beim Erscheinen der Liste (Einblenden/Gleiten)';

  @override
  String get listEntranceAnimationDesc =>
      'Listenelemente beim Laden animiert einblenden und gleiten lassen.';

  @override
  String get hapticsTouch => 'Haptisches Feedback';

  @override
  String get hapticsFeedback => 'Haptisches Feedback';

  @override
  String get hapticsFeedbackDesc =>
      'Bietet feine Vibrationen bei Interaktionen für taktiles Feedback.';

  @override
  String get advancedTuning => 'Erweiterte Feinabstimmung';

  @override
  String get advancedTuningDesc =>
      'Feinabstimmung erweiterter Parameter für die Animationen.';

  @override
  String get notificationsUpdates => 'Benachrichtigungen & Updates';

  @override
  String get updateCheckNotify => 'Update-Benachrichtigungen';

  @override
  String get updateCheckNotifyDesc =>
      'Prüft beim Start auf die neuesten Flowscout-Releases und benachrichtigt, wenn Updates verfügbar sind.';

  @override
  String get githubIntegration => 'GitHub-Integration';

  @override
  String get addNewAccount => 'Neues Konto hinzufügen';

  @override
  String get addNewAccountDesc =>
      'Ein weiteres GitHub-Konto verbinden.\\n* Es ist einfacher, wenn Sie bereits in diesem Konto in Ihrem Browser angemeldet sind.';

  @override
  String get manageAccounts => 'Konten verwalten';

  @override
  String get manageAccountsDesc =>
      'Installieren und verwalten Sie die GitHub-App für neue Organisationen oder persönliche Konten.';

  @override
  String get dangerZone => 'Gefahrenbereich';

  @override
  String get aboutApp => 'Über diese App';

  @override
  String get accessibilitySupport => 'Barrierefreiheit-Unterstützung';

  @override
  String get accessibilitySupportDesc =>
      'Entwickelt in Übereinstimmung mit den Richtlinien WCAG 2.2, Apple HIG Accessibility und Android Build Accessible Apps.';

  @override
  String get springScaleFactor => 'Skalierungsfaktor beim Tippen';

  @override
  String get springScaleFactorDisabled =>
      'Skalierungsfaktor beim Tippen (Aktivieren Sie den obigen Schalter zum Anpassen)';

  @override
  String get shimmerSpeed => 'Shimmer-Geschwindigkeit';

  @override
  String get shimmerSpeedDisabled =>
      'Shimmer-Geschwindigkeit (Aktivieren Sie den obigen Schalter zum Anpassen)';

  @override
  String get vibrationStrength => 'Vibrationsstärke';

  @override
  String get vibrationStrengthDisabled =>
      'Vibrationsstärke (Aktivieren Sie den obigen Schalter zum Anpassen)';

  @override
  String get hapticLight => 'Leicht (Subtil)';

  @override
  String get hapticMedium => 'Mittel (Standard)';

  @override
  String get hapticHeavy => 'Stark (Kräftig)';

  @override
  String get hapticSelection => 'Auswahl (Klick-Effekt)';

  @override
  String get guestModeActive => 'Gastmodus aktiv';

  @override
  String get guestModeDesc =>
      'Nicht mit einem GitHub-Konto verbunden (nur Suche nach öffentlichen Informationen).';

  @override
  String get noAccountRegistered => 'Kein Konto registriert';

  @override
  String get currentlyActive => 'Aktiv';

  @override
  String get tapToSwitch => 'Tippen zum Wechseln';

  @override
  String get confirmDisconnectAllTitle => 'Alle Konten trennen?';

  @override
  String get confirmDisconnectTitle => 'Konto trennen?';

  @override
  String get confirmDisconnectAllDesc =>
      'Alle GitHub-Konten werden getrennt und Sie werden abgemeldet.';

  @override
  String confirmDisconnectDesc(String username) {
    return 'Die Verbindung zum aktuellen Konto (@$username) trennen.';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get disconnect => 'Trennen';

  @override
  String get endGuestMode => 'Gastmodus beenden & anmelden';

  @override
  String get endGuestModeDesc =>
      'Gehen Sie zurück zum Anmeldebildschirm, um Ihr GitHub-Konto zu verknüpfen.';

  @override
  String get disconnectCurrent => 'Aktuelles Konto trennen';

  @override
  String get disconnectCurrentDesc =>
      'Trennen Sie nur das ausgewählte Konto von diesem Gerät.';

  @override
  String get logoutAll => 'Alle trennen & abmelden';

  @override
  String get logoutAllDesc =>
      'Entfernen Sie alle registrierten Kontoinformationen von diesem Gerät.';

  @override
  String get updateInfoTitle => 'Update-Hinweis';

  @override
  String newVersionAvailable(String version) {
    return 'Neue Version $version ist verfügbar!';
  }

  @override
  String currentVersion(String version) {
    return 'Aktuelle Version: $version';
  }

  @override
  String get releaseNotes => 'Versionshinweise:';

  @override
  String get releaseNotesFallback =>
      'Fehlerbehebungen und Leistungsverbesserungen.';

  @override
  String get later => 'Später';

  @override
  String get update => 'Aktualisieren';

  @override
  String get themeToggle => 'Design umschalten';

  @override
  String get searchHintText =>
      'Geben Sie den Namen des gesuchten Repositorys ein';

  @override
  String get repositories => 'Repositorys';

  @override
  String get sortOrderTooltip => 'Sortieren';

  @override
  String get sortLastCiRun => 'Letzter CI/CD-Lauf';

  @override
  String get noRepositoriesFound => 'Keine Repositorys gefunden';

  @override
  String errorOccurred(String error) {
    return 'Ein Fehler ist aufgetreten: $error';
  }

  @override
  String get filter => 'Filter';

  @override
  String get filterConditions => 'Filterbedingungen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get repositoryType => 'Repository-Typ';

  @override
  String get ownerType => 'Besitzer-Typ';

  @override
  String get account => 'Konto';

  @override
  String get all => 'Alle';

  @override
  String get personal => 'Persönlich';

  @override
  String get organization => 'Organisation';

  @override
  String get applyFilter => 'Filter anwenden';

  @override
  String get authPageOpenError =>
      'Die Authentifizierungsseite konnte nicht geöffnet werden.';

  @override
  String authPageError(String error) {
    return 'Beim Öffnen der Authentifizierungsseite ist ein Fehler aufgetreten: $error';
  }

  @override
  String get invalidTokenError =>
      'Ungültiges Token. Bitte geben Sie ein gültiges Personal Access Token ein.';

  @override
  String get appSubtitle => 'GitHub CI/CD Monitoring-App';

  @override
  String get connectWithGithub => 'Mit GitHub-App verbinden';

  @override
  String get connectWithGithubDesc =>
      'Sicher und schnell über die GitHub-App verbinden.';

  @override
  String get skipGuestMode => 'Überspringen und Gastmodus verwenden';

  @override
  String get connectWithPat => 'Oder mit Personal Access Token verbinden';

  @override
  String get enterToken => 'Bitte geben Sie Ihr Token ein';

  @override
  String get connectWithPatBtn => 'Mit PAT verbinden';

  @override
  String get generateTokenOnGithub => 'Token auf GitHub generieren';

  @override
  String get whatIsPat => 'Was ist ein Personal Access Token?';

  @override
  String get patStep1 =>
      'GitHub-Einstellungen → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => 'Klicken Sie auf \"Generate new token (classic)\"';

  @override
  String get patStep3 => 'Wählen Sie die Scopes: repo, read:user, workflow';

  @override
  String get patStep4 =>
      'Geben Sie das generierte Token (ghp_...) in das Feld ein.';
}
