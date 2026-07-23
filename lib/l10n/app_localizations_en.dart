// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get appTitle => 'ShelfTracker';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get dashboardReadingLog => 'Reading\nLog';

  @override
  String get dashboardBookshelf => 'Bookshelf';

  @override
  String get dashboardAddBook => 'Add Book';

  @override
  String get dashboardWishlist => 'Wishlist';
}
