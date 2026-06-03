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
}
