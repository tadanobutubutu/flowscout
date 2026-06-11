// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'Rechercher des dépôts...';

  @override
  String get myRepositories => 'Mes Dépôts';

  @override
  String get settings => 'Paramètres';

  @override
  String get selectOrder => 'Ordre';

  @override
  String get sortLastUpdated => 'Dernière mise à jour';

  @override
  String get sortName => 'Nom';

  @override
  String get sortStars => 'Étoiles';

  @override
  String get settingsTitle => 'Paramètres avancés';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get displayLanguage => 'Langue d\'affichage';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get powerPerformance => 'Puissance et performances';

  @override
  String get lowSpecMode => 'Mode économie d\'énergie et performances réduites';

  @override
  String get lowSpecModeDesc =>
      'Désactive les animations premium et les effets de scintillement (shimmer), et passe à une interface utilisateur plate pour réduire la consommation de la batterie et la charge de l\'appareil.';

  @override
  String get springAnimation => 'Animation physique de ressort';

  @override
  String get springAnimationDesc =>
      'Active le retour physique de ressort lors de l\'appui sur les boutons.';

  @override
  String get shimmerLoading => 'Chargement avec scintillement';

  @override
  String get shimmerLoadingDesc =>
      'Affiche un écran squelette scintillant pendant le chargement des données.';

  @override
  String get listEntranceAnimation =>
      'Animation d\'apparition de la liste (Fondu/Glissement)';

  @override
  String get listEntranceAnimationDesc =>
      'Anime l\'apparition des éléments de la liste avec un effet de fondu et de glissement lors du chargement.';

  @override
  String get hapticsTouch => 'Retour haptique';

  @override
  String get hapticsFeedback => 'Retour haptique';

  @override
  String get hapticsFeedbackDesc =>
      'Fournit de légères vibrations lors des interactions pour un retour tactile.';

  @override
  String get advancedTuning => 'Réglages avancés';

  @override
  String get advancedTuningDesc =>
      'Ajuste les paramètres avancés des animations.';

  @override
  String get notificationsUpdates => 'Notifications et mises à jour';

  @override
  String get updateCheckNotify => 'Notifications de mise à jour';

  @override
  String get updateCheckNotifyDesc =>
      'Vérifie les dernières versions de Flowscout au démarrage et avertit si des mises à jour sont disponibles.';

  @override
  String get githubIntegration => 'Intégration GitHub';

  @override
  String get addNewAccount => 'Ajouter un nouveau compte';

  @override
  String get addNewAccountDesc =>
      'Connecter un autre compte GitHub.\\n* C\'est plus simple si vous êtes déjà connecté à ce compte dans votre navigateur.';

  @override
  String get manageAccounts => 'Gérer les comptes';

  @override
  String get manageAccountsDesc =>
      'Installer et gérer l\'application GitHub sur de nouvelles organisations ou comptes personnels.';

  @override
  String get dangerZone => 'Zone de danger';

  @override
  String get aboutApp => 'À propos de cette application';

  @override
  String get accessibilitySupport => 'Prise en charge de l\'accessibilité';

  @override
  String get accessibilitySupportDesc =>
      'Conçu conformément aux directives WCAG 2.2, Apple HIG Accessibility et Android Build Accessible Apps.';

  @override
  String get springScaleFactor => 'Facteur d\'échelle au toucher';

  @override
  String get springScaleFactorDisabled =>
      'Facteur d\'échelle au toucher (Activez le commutateur ci-dessus pour ajuster)';

  @override
  String get shimmerSpeed => 'Vitesse du scintillement';

  @override
  String get shimmerSpeedDisabled =>
      'Vitesse du scintillement (Activez le commutateur ci-dessus pour ajuster)';

  @override
  String get vibrationStrength => 'Force de vibration';

  @override
  String get vibrationStrengthDisabled =>
      'Force de vibration (Activez le commutateur ci-dessus pour ajuster)';

  @override
  String get hapticLight => 'Léger (Subtil)';

  @override
  String get hapticMedium => 'Moyen (Par défaut)';

  @override
  String get hapticHeavy => 'Fort (Puissant)';

  @override
  String get hapticSelection => 'Sélection (Effet de clic)';

  @override
  String get guestModeActive => 'Utilisation du mode invité';

  @override
  String get guestModeDesc =>
      'Non connecté à un compte GitHub (recherche d\'informations publiques uniquement).';

  @override
  String get noAccountRegistered => 'Aucun compte enregistré';

  @override
  String get currentlyActive => 'Actif';

  @override
  String get tapToSwitch => 'Appuyer pour basculer';

  @override
  String get confirmDisconnectAllTitle => 'Déconnecter tous les comptes ?';

  @override
  String get confirmDisconnectTitle => 'Déconnecter le compte ?';

  @override
  String get confirmDisconnectAllDesc =>
      'Tous les comptes GitHub seront déconnectés et vous serez déconnecté.';

  @override
  String confirmDisconnectDesc(String username) {
    return 'Déconnecter le compte actuel (@$username).';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get endGuestMode => 'Quitter le mode invité et se connecter';

  @override
  String get endGuestModeDesc =>
      'Retourner à l\'écran de connexion pour lier votre compte GitHub.';

  @override
  String get disconnectCurrent => 'Déconnecter le compte actuel';

  @override
  String get disconnectCurrentDesc =>
      'Déconnecter uniquement le compte sélectionné de cet appareil.';

  @override
  String get logoutAll => 'Déconnecter tout et se déconnecter';

  @override
  String get logoutAllDesc =>
      'Supprimer toutes les informations de compte enregistrées de l\'appareil.';

  @override
  String get updateInfoTitle => 'Avis de mise à jour';

  @override
  String newVersionAvailable(String version) {
    return 'La nouvelle version $version est disponible !';
  }

  @override
  String currentVersion(String version) {
    return 'Version actuelle : $version';
  }

  @override
  String get releaseNotes => 'Notes de version :';

  @override
  String get releaseNotesFallback =>
      'Corrections de bogues et améliorations des performances.';

  @override
  String get later => 'Plus tard';

  @override
  String get update => 'Mettre à jour';

  @override
  String get themeToggle => 'Changer de thème';

  @override
  String get searchHintText =>
      'Entrez le nom du dépôt que vous souhaitez rechercher';

  @override
  String get repositories => 'Dépôts';

  @override
  String get sortOrderTooltip => 'Trier';

  @override
  String get sortLastCiRun => 'Dernière exécution CI/CD';

  @override
  String get noRepositoriesFound => 'Aucun dépôt trouvé';

  @override
  String errorOccurred(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get filter => 'Filtrer';

  @override
  String get filterConditions => 'Conditions de filtrage';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get repositoryType => 'Type de dépôt';

  @override
  String get ownerType => 'Type de propriétaire';

  @override
  String get account => 'Compte';

  @override
  String get all => 'Tout';

  @override
  String get personal => 'Personnel';

  @override
  String get organization => 'Organisation';

  @override
  String get applyFilter => 'Appliquer les filtres';

  @override
  String get authPageOpenError =>
      'Impossible d\'ouvrir la page d\'authentification.';

  @override
  String authPageError(String error) {
    return 'Une erreur est survenue lors de l\'ouverture de la page d\'authentification : $error';
  }

  @override
  String get invalidTokenError =>
      'Jeton invalide. Veuillez entrer un Personal Access Token valide.';

  @override
  String get appSubtitle => 'Application de suivi GitHub CI/CD';

  @override
  String get connectWithGithub => 'Se connecter avec l\'application GitHub';

  @override
  String get connectWithGithubDesc =>
      'Se connecter de manière sécurisée et rapide à l\'aide de l\'application GitHub.';

  @override
  String get skipGuestMode => 'Passer et utiliser le mode invité';

  @override
  String get connectWithPat => 'Ou se connecter avec un Personal Access Token';

  @override
  String get enterToken => 'Veuillez entrer votre jeton';

  @override
  String get connectWithPatBtn => 'Se connecter avec PAT';

  @override
  String get generateTokenOnGithub => 'Générer un jeton sur GitHub';

  @override
  String get whatIsPat => 'Qu\'est-ce qu\'un Personal Access Token ?';

  @override
  String get patStep1 =>
      'Paramètres GitHub → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => 'Cliquez sur « Generate new token (classic) »';

  @override
  String get patStep3 => 'Sélectionnez les portées : repo, read:user, workflow';

  @override
  String get patStep4 => 'Entrez le jeton généré (ghp_...) dans le champ.';

  @override
  String get sortBestMatch => 'Meilleur résultat';

  @override
  String get searchTypeRepos => 'Dépôts';

  @override
  String get searchTypeUsers => 'Utilisateurs & Orgs';

  @override
  String get userProfile => 'Profil';
}
