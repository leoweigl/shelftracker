// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get appTitle => 'ShelfTracker';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get dashboardReadingLog => 'Lesetagebuch';

  @override
  String get dashboardBookshelf => 'Bücherregal';

  @override
  String get dashboardAddBook => 'Buch hinzufügen';

  @override
  String get dashboardWishlist => 'Wunschliste';
}
