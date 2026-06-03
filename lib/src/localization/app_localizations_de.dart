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
  String get selectOrder => 'Order';

  @override
  String get sortLastUpdated => 'Last updated';

  @override
  String get sortName => 'Name';

  @override
  String get sortStars => 'Stars';
}
