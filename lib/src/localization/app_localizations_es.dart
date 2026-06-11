// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'Buscar repositorios...';

  @override
  String get myRepositories => 'Mis Repositorios';

  @override
  String get settings => 'Ajustes';

  @override
  String get selectOrder => 'Orden';

  @override
  String get sortLastUpdated => 'Última actualización';

  @override
  String get sortName => 'Nombre';

  @override
  String get sortStars => 'Estrellas';

  @override
  String get settingsTitle => 'Configuración avanzada';

  @override
  String get languageSettings => 'Configuración de idioma';

  @override
  String get displayLanguage => 'Idioma de pantalla';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get powerPerformance => 'Rendimiento y energía';

  @override
  String get lowSpecMode => 'Ahorro de energía y modo de bajo rendimiento';

  @override
  String get lowSpecModeDesc =>
      'Desactiva las animaciones premium y los efectos de brillo, cambiando a una interfaz de usuario plana para reducir el consumo de batería y la carga del dispositivo.';

  @override
  String get springAnimation => 'Animación física de resorte';

  @override
  String get springAnimationDesc =>
      'Habilita la retroalimentación física de resorte al tocar botones.';

  @override
  String get shimmerLoading => 'Carga con efecto de brillo (Shimmer)';

  @override
  String get shimmerLoadingDesc =>
      'Muestra una pantalla de esqueleto brillante mientras se cargan los datos.';

  @override
  String get listEntranceAnimation =>
      'Animación de entrada de lista (Desvanecimiento/Deslizamiento)';

  @override
  String get listEntranceAnimationDesc =>
      'Animes los elementos de la lista desvaneciéndose y deslizándose al cargarse.';

  @override
  String get hapticsTouch => 'Retroalimentación háptica';

  @override
  String get hapticsFeedback => 'Retroalimentación háptica';

  @override
  String get hapticsFeedbackDesc =>
      'Proporciona vibraciones sutiles en las interacciones para sentir una respuesta táctil.';

  @override
  String get advancedTuning => 'Ajuste avanzado';

  @override
  String get advancedTuningDesc =>
      'Ajusta parámetros avanzados de las animaciones.';

  @override
  String get notificationsUpdates => 'Notificaciones y actualizaciones';

  @override
  String get updateCheckNotify => 'Notificaciones de actualización';

  @override
  String get updateCheckNotifyDesc =>
      'Busca las últimas versiones de Flowscout al iniciar y notifica si hay actualizaciones disponibles.';

  @override
  String get githubIntegration => 'Integración con GitHub';

  @override
  String get addNewAccount => 'Añadir nueva cuenta';

  @override
  String get addNewAccountDesc =>
      'Conecta otra cuenta de GitHub.\\n* Es más fácil si ya has iniciado sesión en esa cuenta en tu navegador.';

  @override
  String get manageAccounts => 'Administrar cuentas';

  @override
  String get manageAccountsDesc =>
      'Instala y administra la aplicación de GitHub en nuevas organizaciones o cuentas personales.';

  @override
  String get dangerZone => 'Zona de peligro';

  @override
  String get aboutApp => 'Acerca de esta aplicación';

  @override
  String get accessibilitySupport => 'Soporte de accesibilidad';

  @override
  String get accessibilitySupportDesc =>
      'Diseñado en conformidad con las directrices WCAG 2.2, Apple HIG Accessibility y Android Build Accessible Apps.';

  @override
  String get springScaleFactor => 'Factor de escala al tocar';

  @override
  String get springScaleFactorDisabled =>
      'Factor de escala al tocar (Activa el interruptor de arriba para ajustar)';

  @override
  String get shimmerSpeed => 'Velocidad de brillo';

  @override
  String get shimmerSpeedDisabled =>
      'Velocidad de brillo (Activa el interruptor de arriba para ajustar)';

  @override
  String get vibrationStrength => 'Fuerza de vibración';

  @override
  String get vibrationStrengthDisabled =>
      'Fuerza de vibración (Activa el interruptor de arriba para ajustar)';

  @override
  String get hapticLight => 'Ligero (Sutil)';

  @override
  String get hapticMedium => 'Medio (Predeterminado)';

  @override
  String get hapticHeavy => 'Pesado (Fuerte)';

  @override
  String get hapticSelection => 'Selección (Efecto de clic)';

  @override
  String get guestModeActive => 'Usando el modo de invitado';

  @override
  String get guestModeDesc =>
      'No conectado a una cuenta de GitHub (solo búsqueda de información pública).';

  @override
  String get noAccountRegistered => 'Ninguna cuenta registrada';

  @override
  String get currentlyActive => 'Activo';

  @override
  String get tapToSwitch => 'Toca para cambiar';

  @override
  String get confirmDisconnectAllTitle => '¿Desconectar todas las cuentas?';

  @override
  String get confirmDisconnectTitle => '¿Desconectar cuenta?';

  @override
  String get confirmDisconnectAllDesc =>
      'Se desconectarán todas las cuentas de GitHub y se cerrará la sesión.';

  @override
  String confirmDisconnectDesc(String username) {
    return 'Desconectar la cuenta actual (@$username).';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get endGuestMode => 'Salir del modo de invitado e iniciar sesión';

  @override
  String get endGuestModeDesc =>
      'Regresa a la pantalla de inicio de sesión para vincular tu cuenta de GitHub.';

  @override
  String get disconnectCurrent => 'Desconectar cuenta actual';

  @override
  String get disconnectCurrentDesc =>
      'Desconectar solo la cuenta seleccionada de este dispositivo.';

  @override
  String get logoutAll => 'Desconectar todas y cerrar sesión';

  @override
  String get logoutAllDesc =>
      'Elimina toda la información de las cuentas registradas del dispositivo.';

  @override
  String get updateInfoTitle => 'Aviso de actualización';

  @override
  String newVersionAvailable(String version) {
    return '¡La nueva versión $version está disponible!';
  }

  @override
  String currentVersion(String version) {
    return 'Versión actual: $version';
  }

  @override
  String get releaseNotes => 'Notas de la versión:';

  @override
  String get releaseNotesFallback =>
      'Corrección de errores y mejoras de rendimiento.';

  @override
  String get later => 'Más tarde';

  @override
  String get update => 'Actualizar';

  @override
  String get themeToggle => 'Alternar tema';

  @override
  String get searchHintText =>
      'Introduce el nombre del repositorio que deseas buscar';

  @override
  String get repositories => 'Repositorios';

  @override
  String get sortOrderTooltip => 'Ordenar';

  @override
  String get sortLastCiRun => 'Última ejecución de CI/CD';

  @override
  String get noRepositoriesFound => 'No se encontraron repositorios';

  @override
  String errorOccurred(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get filter => 'Filtrar';

  @override
  String get filterConditions => 'Conditions de filtrado';

  @override
  String get reset => 'Restablecer';

  @override
  String get repositoryType => 'Tipo de repositorio';

  @override
  String get ownerType => 'Tipo de propietario';

  @override
  String get account => 'Cuenta';

  @override
  String get all => 'Todos';

  @override
  String get personal => 'Personal';

  @override
  String get organization => 'Organización';

  @override
  String get applyFilter => 'Aplicar filtros';

  @override
  String get authPageOpenError =>
      'No se pudo abrir la página de autenticación.';

  @override
  String authPageError(String error) {
    return 'Ocurrió un error al abrir la página de autenticación: $error';
  }

  @override
  String get invalidTokenError =>
      'Token no válido. Introduce un Personal Access Token válido.';

  @override
  String get appSubtitle => 'Aplicación de monitoreo de GitHub CI/CD';

  @override
  String get connectWithGithub => 'Conectar con GitHub App';

  @override
  String get connectWithGithubDesc =>
      'Conéctate de forma segura y rápida con la GitHub App.';

  @override
  String get skipGuestMode => 'Omitir y usar el modo de invitado';

  @override
  String get connectWithPat => 'Or conectarse con Personal Access Token';

  @override
  String get enterToken => 'Introduce tu token';

  @override
  String get connectWithPatBtn => 'Conectar con PAT';

  @override
  String get generateTokenOnGithub => 'Generar token en GitHub';

  @override
  String get whatIsPat => '¿Qué es un Personal Access Token?';

  @override
  String get patStep1 =>
      'Configuración de GitHub → Developer settings → Personal access tokens → Tokens (classic)';

  @override
  String get patStep2 => 'Haz clic en \"Generate new token (classic)\"';

  @override
  String get patStep3 => 'Selecciona los ámbitos: repo, read:user, workflow';

  @override
  String get patStep4 => 'Introduce el token generado (ghp_...) en el campo.';

  @override
  String get sortBestMatch => 'Mejor coincidencia';

  @override
  String get searchTypeRepos => 'Repositorios';

  @override
  String get searchTypeUsers => 'Usuarios y Orgs';

  @override
  String get userProfile => 'Perfil';
}
