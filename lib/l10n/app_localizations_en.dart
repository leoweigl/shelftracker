// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get themeEbonyClay => 'Midnight';

  @override
  String get themeSepia => 'Parchment';

  @override
  String get themeStone => 'Slate';

  @override
  String get themeIndigoNight => 'Twilight';

  @override
  String get themeViolet => 'Amethyst';

  @override
  String get themeCrimson => 'Ruby';

  @override
  String get themeGreen => 'Emerald';

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

  @override
  String get detailRemoveFav => 'Remove from favorites';

  @override
  String get detailAddFav => 'Add to favorites';

  @override
  String get askDeleteBook => 'Delete book?';

  @override
  String get askDeleteLog => 'Delete entry?';

  @override
  String get deleteLog => 'Delete entry';

  @override
  String get confirmDelete => ' will be removed from your shelf.';

  @override
  String get confirmDeleteWishlist => ' will be removed from your wishlist.';

  @override
  String get confirmDeleteLog =>
      'This reading entry will be permanently removed from the log.';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get deleteBook => 'Delete book';

  @override
  String get rating => 'Rating';

  @override
  String get status => 'Status';

  @override
  String get keep => 'Keep';

  @override
  String get forSale => 'For sale';

  @override
  String get categories => 'Categories';

  @override
  String get add => 'Add';

  @override
  String get noDescrAvailable => 'No description available';

  @override
  String get description => 'Description';

  @override
  String get dateFormat => 'MM/dd/yyyy';

  @override
  String get addedOn => 'Added on';

  @override
  String get searchOrCreate => 'Search or create new';

  @override
  String get createCategory => 'Create';

  @override
  String get noMoreCategories => 'No more categories.';

  @override
  String get done => 'Done';

  @override
  String get bookshelf => 'Bookshelf';

  @override
  String get closeSearch => 'Close search';

  @override
  String get search => 'Search';

  @override
  String get sort => 'Sort by';

  @override
  String get asc => 'Ascending';

  @override
  String get desc => 'Descending';

  @override
  String get searchTitleOrAuthor => 'Search title or author...';

  @override
  String get noBooksYet => 'No books yet.';

  @override
  String get noBooksMatch => 'No books match your search.';

  @override
  String get favorite => 'Favorite';

  @override
  String get notYetRated => 'not yet rated';

  @override
  String get title => 'Title';

  @override
  String get author => 'Author';

  @override
  String get keepSell => 'Keep / Sell';

  @override
  String get added => 'Added';

  @override
  String get changeReadDate => 'Change read date';

  @override
  String get readOn => 'Read on';

  @override
  String get readingLog => 'Reading Log';

  @override
  String get noLogsYet => 'No read books logged yet.';

  @override
  String get noEntriesMatch => 'No entries match your search.';

  @override
  String get notInShelf => 'not in shelf';

  @override
  String get scanIsbn => 'Scan ISBN';

  @override
  String get scanIsbnHelpText =>
      'Point the camera at the barcode on the back of the book.';

  @override
  String get searchError => 'Search error:';

  @override
  String get searchBook => 'Search book';

  @override
  String get enterTitleAuthorIsbn => 'Enter title, author or ISBN...';

  @override
  String get selectBook => 'Select book';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get addToWishlist => 'Add to wishlist';

  @override
  String get statusWishlisted => 'Wishlisted';

  @override
  String get statusPreordered => 'Pre-ordered';

  @override
  String get statusOnShelf => 'On shelf';

  @override
  String noFilteredBooks(String filter) {
    String _temp0 = intl.Intl.selectLogic(filter, {
      'all': 'No books.',
      'wishlist': 'No wishlisted books.',
      'preordered': 'No pre-ordered books.',
      'other': 'No books.',
    });
    return '$_temp0';
  }

  @override
  String get all => 'All';

  @override
  String get moveToShelf => 'Move to Shelf';

  @override
  String get logAsRead => 'Log as read';

  @override
  String get markAsPreordered => 'Mark as pre-ordered';

  @override
  String get removePreorder => 'Remove pre-order';

  @override
  String get movedToShelf => 'moved to shelf';

  @override
  String get loggedAsRead => 'logged as read';

  @override
  String get markedAsPreordered => 'marked as pre-ordered';

  @override
  String get removedPreorder => 'Removed pre-order for';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get unknown => 'Unknown';

  @override
  String get noTitle => 'Untitled';

  @override
  String get addBookTitle => 'Add book';

  @override
  String get saveAsTitle => 'Save as';

  @override
  String get alreadyRead => 'Already read';

  @override
  String get alreadyReadSubtitle => 'Adds to shelf and creates a log entry';

  @override
  String get toShelf => 'To shelf';

  @override
  String get toShelfSubtitle => 'Adds to shelf only, no log entry';

  @override
  String get wishlistSubtitle => 'For books you don\'t own yet';

  @override
  String noResultsForIsbn(String isbn) {
    return 'No results for ISBN $isbn';
  }

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get addedToShelf => 'added to shelf';

  @override
  String get addedToWishlist => 'added to wishlist';

  @override
  String get alreadyInShelf => 'is already in your shelf';

  @override
  String get alreadyPreorderedMsg => 'is already pre-ordered';

  @override
  String get alreadyOnWishlist => 'is already on your wishlist';
}
