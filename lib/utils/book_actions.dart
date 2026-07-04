import 'package:flutter/material.dart';
import 'package:shelftracker/models/wishlist_add_result.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';
import '../screens/search_screen.dart';
import '../screens/scanner_screen.dart';

enum _FindMethod { scan, search }

enum _SaveAs { alreadyRead, inShelf, wishlist }

Future<void> showAddBookOptions(BuildContext context) async {
  final book = await _findBook(context);
  if (book == null || !context.mounted) return;

  final saveAs = await _showSaveAsDialog(context);
  if (saveAs == null || !context.mounted) return;

  switch (saveAs) {
    case _SaveAs.alreadyRead:
      await bookRepository.logBookAsRead(book);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title}" logged as read')),
      );
      break;

    case _SaveAs.inShelf:
      await bookRepository.addToShelf(book);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${book.title}" added to shelf')),
      );
      break;

    case _SaveAs.wishlist:
      final result = await bookRepository.addToWishlist(book);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_wishlistMessage(book.title, result))),
      );
      break;
  }
}

Future<Book?> _findBook(BuildContext context) async {
  final method = await showDialog<_FindMethod>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Add book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan ISBN'),
            onTap: () => Navigator.pop(dialogContext, _FindMethod.scan),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search book'),
            onTap: () => Navigator.pop(dialogContext, _FindMethod.search),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
        ),
      ],
    ),
  );

  if (method == null || !context.mounted) return null;

  if (method == _FindMethod.search) {
    return Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  final isbn = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );
  if (isbn == null || !context.mounted) return null;

  try {
    final book = await BookApiService().searchByIsbn(isbn);
    if (book == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No results for ISBN $isbn')),
      );
    }
    return book;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    return null;
  }
}

Future<_SaveAs?> _showSaveAsDialog(BuildContext context) {
  return showDialog<_SaveAs>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Save as'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.done_all),
            title: const Text('Already read'),
            subtitle: const Text('Adds to shelf and creates a log entry'),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.alreadyRead),
          ),
          ListTile(
            leading: const Icon(Icons.shelves),
            title: const Text('To shelf'),
            subtitle: const Text('Adds to shelf only, no log entry'),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.inShelf),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Wishlist'),
            subtitle: const Text('For books you don\'t own yet'),
            onTap: () => Navigator.pop(dialogContext, _SaveAs.wishlist),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

String _wishlistMessage(String title, WishlistAddResult result) {
  switch (result) {
    case WishlistAddResult.added:
      return '"$title" added to wishlist';
    case WishlistAddResult.alreadyOwned:
      return '"$title" is already in your shelf';
    case WishlistAddResult.alreadyPreordered:
      return '"$title" is already pre-ordered';
    case WishlistAddResult.alreadyWishlisted:
      return '"$title" is already on your wishlist';
  }
}

Future<void> addToWishlistViaSearch(BuildContext context) async {
  final book = await Navigator.push<Book>(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
  );
  if (book == null || !context.mounted) return;

  final result = await bookRepository.addToWishlist(book);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_wishlistMessage(book.title, result))),
  );
}