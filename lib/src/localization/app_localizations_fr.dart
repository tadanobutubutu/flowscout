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
  String get selectOrder => 'Order';

  @override
  String get sortLastUpdated => 'Last updated';

  @override
  String get sortName => 'Name';

  @override
  String get sortStars => 'Stars';
}
