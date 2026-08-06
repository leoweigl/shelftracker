import 'package:flutter/material.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import 'package:shelftracker/models/wishlist_add_result.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';
import '../screens/search_screen.dart';
import '../screens/scanner_screen.dart';

enum _FindMethod { scan, search }

enum _SaveAs { alreadyRead, inShelf, wishlist }

Future<void> showAddBookOptions(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final method = await showDialog<_FindMethod>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.addBookTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: Text(l10n.scanIsbn),
            onTap: () => Navigator.pop(dialogContext, _FindMethod.scan),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: Text(l10n.searchBook),
            onTap: () => Navigator.pop(dialogContext, _FindMethod.search),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
        ),
      ],
    ),
  );

  if (method == null || !context.mounted) return;

  if (method == _FindMethod.search) {
    // The search screen shows the "save as" dialog itself, on top of the
    // results, so a mis-tapped book can be cancelled without losing the list.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(onAddBook: _saveBookWithDialog),
      ),
    );
    return;
  }

  final isbn = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );
  if (isbn == null || !context.mounted) return;

  Book? book;
  try {
    book = await BookApiService().searchByIsbn(isbn);
    if (book == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noResultsForIsbn(isbn))),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPrefix(e.toString()))),
      );
    }
  }
  if (book == null || !context.mounted) return;

  await _saveBookWithDialog(context, book);
}

/// Shows the "save as" dialog for [book] and performs the save.
/// Returns true if the book was saved, false if the dialog was cancelled.
Future<bool> _saveBookWithDialog(BuildContext context, Book book) async {
  final l10n = AppLocalizations.of(context)!;
  final saveAs = await _showSaveAsDialog(context);
  if (saveAs == null || !context.mounted) return false;

  switch (saveAs) {
    case _SaveAs.alreadyRead:
      await bookRepository.logBookAsRead(book);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title ?? l10n.noTitle}" ${l10n.loggedAsRead}')),
      );
      break;

    case _SaveAs.inShelf:
      await bookRepository.addToShelf(book);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title ?? l10n.noTitle}" ${l10n.addedToShelf}')),
      );
      break;

    case _SaveAs.wishlist:
      final result = await bookRepository.addToWishlist(book);
      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_wishlistMessage(l10n, book.title ?? l10n.noTitle, result))),
      );
      break;
  }
  return true;
}

Future<_SaveAs?> _showSaveAsDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<_SaveAs>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.saveAsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.done_all),
            title: Text(l10n.alreadyRead),
            subtitle: Text(l10n.alreadyReadSubtitle),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.alreadyRead),
          ),
          ListTile(
            leading: const Icon(Icons.shelves),
            title: Text(l10n.toShelf),
            subtitle: Text(l10n.toShelfSubtitle),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.inShelf),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(l10n.wishlist),
            subtitle: Text(l10n.wishlistSubtitle),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.wishlist),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}

String _wishlistMessage(AppLocalizations l10n, String title, WishlistAddResult result) {
  switch (result) {
    case WishlistAddResult.added:
      return '"$title" ${l10n.addedToWishlist}';
    case WishlistAddResult.alreadyOwned:
      return '"$title" ${l10n.alreadyInShelf}';
    case WishlistAddResult.alreadyPreordered:
      return '"$title" ${l10n.alreadyPreorderedMsg}';
    case WishlistAddResult.alreadyWishlisted:
      return '"$title" ${l10n.alreadyOnWishlist}';
  }
}

/// Opens the search screen prefilled with [query] (a series volume's title),
/// using the same "save as" flow as the normal add-book entry point.
Future<void> openSeriesVolumeInSearch(BuildContext context, String query) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SearchScreen(
        initialQuery: query,
        onAddBook: _saveBookWithDialog,
      ),
    ),
  );
}

Future<void> addToWishlistViaSearch(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SearchScreen(
        onAddBook: (ctx, book) async {
          final l10n = AppLocalizations.of(ctx)!;
          final result = await bookRepository.addToWishlist(book);
          if (ctx.mounted) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(_wishlistMessage(l10n, book.title ?? l10n.noTitle, result))),
            );
          }
          return true;
        },
      ),
    ),
  );
}