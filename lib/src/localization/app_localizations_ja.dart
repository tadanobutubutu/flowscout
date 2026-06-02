// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Flowscout';

  @override
  String get searchHint => 'リポジトリを検索...';

  @override
  String get myRepositories => 'マイリポジトリ';

  @override
  String get settings => '設定';

  @override
  String get selectOrder => '順序';

  @override
  String get sortLastUpdated => '更新順';

  @override
  String get sortName => '名前順';

  @override
  String get sortStars => 'スター数順';
}
