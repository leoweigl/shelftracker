import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ShelfTracker'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @dashboardReadingLog.
  ///
  /// In en, this message translates to:
  /// **'Reading\nLog'**
  String get dashboardReadingLog;

  /// No description provided for @dashboardBookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get dashboardBookshelf;

  /// No description provided for @dashboardAddBook.
  ///
  /// In en, this message translates to:
  /// **'Add Book'**
  String get dashboardAddBook;

  /// No description provided for @dashboardWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get dashboardWishlist;

  /// No description provided for @detailRemoveFav.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get detailRemoveFav;

  /// No description provided for @detailAddFav.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get detailAddFav;

  /// No description provided for @askDeleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete book?'**
  String get askDeleteBook;

  /// No description provided for @askDeleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get askDeleteLog;

  /// No description provided for @deleteLog.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteLog;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **' will be removed from your shelf.'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteWishlist.
  ///
  /// In en, this message translates to:
  /// **' will be removed from your wishlist.'**
  String get confirmDeleteWishlist;

  /// No description provided for @confirmDeleteLog.
  ///
  /// In en, this message translates to:
  /// **'This reading entry will be permanently removed from the log.'**
  String get confirmDeleteLog;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @deleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete book'**
  String get deleteBook;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @forSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get forSale;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noDescrAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescrAvailable;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'MM/dd/yyyy'**
  String get dateFormat;

  /// No description provided for @addedOn.
  ///
  /// In en, this message translates to:
  /// **'Added on'**
  String get addedOn;

  /// No description provided for @searchOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Search or create new'**
  String get searchOrCreate;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createCategory;

  /// No description provided for @noMoreCategories.
  ///
  /// In en, this message translates to:
  /// **'No more categories.'**
  String get noMoreCategories;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @bookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get bookshelf;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sort;

  /// No description provided for @asc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get asc;

  /// No description provided for @desc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get desc;

  /// No description provided for @searchTitleOrAuthor.
  ///
  /// In en, this message translates to:
  /// **'Search title or author...'**
  String get searchTitleOrAuthor;

  /// No description provided for @noBooksYet.
  ///
  /// In en, this message translates to:
  /// **'No books yet.'**
  String get noBooksYet;

  /// No description provided for @noBooksMatch.
  ///
  /// In en, this message translates to:
  /// **'No books match your search.'**
  String get noBooksMatch;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @notYetRated.
  ///
  /// In en, this message translates to:
  /// **'not yet rated'**
  String get notYetRated;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @keepSell.
  ///
  /// In en, this message translates to:
  /// **'Keep / Sell'**
  String get keepSell;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @changeReadDate.
  ///
  /// In en, this message translates to:
  /// **'Change read date'**
  String get changeReadDate;

  /// No description provided for @readOn.
  ///
  /// In en, this message translates to:
  /// **'Read on'**
  String get readOn;

  /// No description provided for @readingLog.
  ///
  /// In en, this message translates to:
  /// **'Reading Log'**
  String get readingLog;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No read books logged yet.'**
  String get noLogsYet;

  /// No description provided for @noEntriesMatch.
  ///
  /// In en, this message translates to:
  /// **'No entries match your search.'**
  String get noEntriesMatch;

  /// No description provided for @notInShelf.
  ///
  /// In en, this message translates to:
  /// **'not in shelf'**
  String get notInShelf;

  /// No description provided for @scanIsbn.
  ///
  /// In en, this message translates to:
  /// **'Scan ISBN'**
  String get scanIsbn;

  /// No description provided for @scanIsbnHelpText.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the barcode on the back of the book.'**
  String get scanIsbnHelpText;

  /// No description provided for @searchError.
  ///
  /// In en, this message translates to:
  /// **'Search error:'**
  String get searchError;

  /// No description provided for @searchBook.
  ///
  /// In en, this message translates to:
  /// **'Search book'**
  String get searchBook;

  /// No description provided for @enterTitleAuthorIsbn.
  ///
  /// In en, this message translates to:
  /// **'Enter title, author or ISBN...'**
  String get enterTitleAuthorIsbn;

  /// No description provided for @selectBook.
  ///
  /// In en, this message translates to:
  /// **'Select book'**
  String get selectBook;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to wishlist'**
  String get addToWishlist;

  /// No description provided for @statusWishlisted.
  ///
  /// In en, this message translates to:
  /// **'Wishlisted'**
  String get statusWishlisted;

  /// No description provided for @statusPreordered.
  ///
  /// In en, this message translates to:
  /// **'Pre-ordered'**
  String get statusPreordered;

  /// No description provided for @statusOnShelf.
  ///
  /// In en, this message translates to:
  /// **'On shelf'**
  String get statusOnShelf;

  /// No description provided for @noFilteredBooks.
  ///
  /// In en, this message translates to:
  /// **'{filter, select, all{No books.} wishlist{No wishlisted books.} preordered{No pre-ordered books.} other{No books.}}'**
  String noFilteredBooks(String filter);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @moveToShelf.
  ///
  /// In en, this message translates to:
  /// **'Move to Shelf'**
  String get moveToShelf;

  /// No description provided for @logAsRead.
  ///
  /// In en, this message translates to:
  /// **'Log as read'**
  String get logAsRead;

  /// No description provided for @markAsPreordered.
  ///
  /// In en, this message translates to:
  /// **'Mark as pre-ordered'**
  String get markAsPreordered;

  /// No description provided for @removePreorder.
  ///
  /// In en, this message translates to:
  /// **'Remove pre-order'**
  String get removePreorder;

  /// No description provided for @movedToShelf.
  ///
  /// In en, this message translates to:
  /// **'moved to shelf'**
  String get movedToShelf;

  /// No description provided for @loggedAsRead.
  ///
  /// In en, this message translates to:
  /// **'logged as read'**
  String get loggedAsRead;

  /// No description provided for @markedAsPreordered.
  ///
  /// In en, this message translates to:
  /// **'marked as pre-ordered'**
  String get markedAsPreordered;

  /// No description provided for @removedPreorder.
  ///
  /// In en, this message translates to:
  /// **'Removed pre-order for'**
  String get removedPreorder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get noTitle;

  /// No description provided for @addBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get addBookTitle;

  /// No description provided for @saveAsTitle.
  ///
  /// In en, this message translates to:
  /// **'Save as'**
  String get saveAsTitle;

  /// No description provided for @alreadyRead.
  ///
  /// In en, this message translates to:
  /// **'Already read'**
  String get alreadyRead;

  /// No description provided for @alreadyReadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds to shelf and creates a log entry'**
  String get alreadyReadSubtitle;

  /// No description provided for @toShelf.
  ///
  /// In en, this message translates to:
  /// **'To shelf'**
  String get toShelf;

  /// No description provided for @toShelfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds to shelf only, no log entry'**
  String get toShelfSubtitle;

  /// No description provided for @wishlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For books you don\'t own yet'**
  String get wishlistSubtitle;

  /// No description provided for @noResultsForIsbn.
  ///
  /// In en, this message translates to:
  /// **'No results for ISBN {isbn}'**
  String noResultsForIsbn(String isbn);

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

  /// No description provided for @addedToShelf.
  ///
  /// In en, this message translates to:
  /// **'added to shelf'**
  String get addedToShelf;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'added to wishlist'**
  String get addedToWishlist;

  /// No description provided for @alreadyInShelf.
  ///
  /// In en, this message translates to:
  /// **'is already in your shelf'**
  String get alreadyInShelf;

  /// No description provided for @alreadyPreorderedMsg.
  ///
  /// In en, this message translates to:
  /// **'is already pre-ordered'**
  String get alreadyPreorderedMsg;

  /// No description provided for @alreadyOnWishlist.
  ///
  /// In en, this message translates to:
  /// **'is already on your wishlist'**
  String get alreadyOnWishlist;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
