// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get language => 'Sprache';

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

  @override
  String get detailRemoveFav => 'Aus Favoriten entfernen';

  @override
  String get detailAddFav => 'Zu Favoriten hinzufügen';

  @override
  String get askDeleteBook => 'Buch löschen?';

  @override
  String get askDeleteLog => 'Eintrag löschen?';

  @override
  String get deleteLog => 'Eintrag löschen';

  @override
  String get confirmDelete => ' wird aus dem Regal entfernt.';

  @override
  String get confirmDeleteLog =>
      'Dieser Leseeintrag wird dauerhaft vom Tagebuch entfernt.';

  @override
  String get delete => 'Löschen';

  @override
  String get remove => 'Entfernen';

  @override
  String get deleteBook => 'Buch löschen';

  @override
  String get rating => 'Bewertung';

  @override
  String get status => 'Status';

  @override
  String get keep => 'Behalten';

  @override
  String get forSale => 'Zu verkaufen';

  @override
  String get categories => 'Kategorien';

  @override
  String get add => 'Neu';

  @override
  String get noDescrAvailable => 'Keine Beschreibung verfügbar';

  @override
  String get description => 'Beschreibung';

  @override
  String get dateFormat => 'dd.MM.yyyy';

  @override
  String get addedOn => 'Hinzugefügt am';

  @override
  String get searchOrCreate => 'Suchen oder erstellen';

  @override
  String get createCategory => 'Erstelle';

  @override
  String get noMoreCategories => 'Keine weiteren Kategorien.';

  @override
  String get done => 'Fertig';

  @override
  String get bookshelf => 'Bücherregal';

  @override
  String get closeSearch => 'Suche schließen';

  @override
  String get search => 'Suche';

  @override
  String get sort => 'Sortierung';

  @override
  String get asc => 'Aufsteigend';

  @override
  String get desc => 'Absteigend';

  @override
  String get searchTitleOrAuthor => 'Suche Titel oder Autor...';

  @override
  String get noBooksYet => 'Noch keine Bücher vorhanden.';

  @override
  String get noBooksMatch => 'Keine Bücher entsprechen den Suchkriterien.';

  @override
  String get favorite => 'Favorit';

  @override
  String get notYetRated => 'noch nicht bewertet';

  @override
  String get title => 'Titel';

  @override
  String get author => 'Autor';

  @override
  String get keepSell => 'Behalten / Verkaufen';

  @override
  String get added => 'Hinzugefügt';

  @override
  String get changeReadDate => 'Lesedatum ändern';

  @override
  String get readOn => 'Gelesen am';

  @override
  String get readingLog => 'Lesetagebuch';

  @override
  String get noLogsYet => 'Bisher wurden noch keine Leseeinträge erstellt.';

  @override
  String get noEntriesMatch => 'Keine Einträge entsprechen den Suchkriterien.';

  @override
  String get notInShelf => 'nicht im Bücherregal';

  @override
  String get scanIsbn => 'ISBN scannen';

  @override
  String get scanIsbnHelpText =>
      'Richte die Kamera auf den Barcode hinten am Buch.';

  @override
  String get searchError => 'Fehler bei der Suche:';

  @override
  String get searchBook => 'Buch suchen';

  @override
  String get enterTitleAuthorIsbn => 'Titel, Autor oder ISBN eingeben...';

  @override
  String get selectBook => 'Buch auswählen';

  @override
  String get wishlist => 'Wunschliste';

  @override
  String get addToWishlist => 'Zur Wunschliste hinzufügen';

  @override
  String get statusWishlisted => 'Wunschliste';

  @override
  String get statusPreordered => 'Vorbestellt';

  @override
  String get statusOnShelf => 'Im Regal';

  @override
  String noFilteredBooks(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'Keine Bücher.',
      'wishlist': 'Keine Bücher auf der Wunschliste.',
      'preordered': 'Keine vorbestellten Bücher.',
      'other': 'Keine Bücher.',
    });
    return '$_temp0';
  }

  @override
  String get all => 'Alle';

  @override
  String get moveToShelf => 'In\'s Regal stellen';

  @override
  String get logAsRead => 'Leseeintrag erstellen';

  @override
  String get markAsPreordered => 'Als vorbestellt markieren';

  @override
  String get removePreorder => 'Vorbestellung entfernen';

  @override
  String get movedToShelf => 'in\'s Regal gestellt';

  @override
  String get loggedAsRead => 'als gelesen markiert';

  @override
  String get markedAsPreordered => 'als vorbestellt markiert';

  @override
  String get removedPreorder => 'Vorbestellung entfernt für';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'Fertig';
}
