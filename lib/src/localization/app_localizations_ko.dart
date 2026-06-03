// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => '저장소 검색...';

  @override
  String get myRepositories => '내 저장소';

  @override
  String get settings => '설정';

  @override
  String get selectOrder => 'Order';

  @override
  String get sortLastUpdated => 'Last updated';

  @override
  String get sortName => 'Name';

  @override
  String get sortStars => 'Stars';
}
