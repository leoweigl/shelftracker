import 'package:flutter/material.dart';
import '../main.dart';
import '../models/book.dart';
import '../database/app_database.dart';
import '../services/book_api_service.dart';
import '../screens/search_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/wishlist_screen.dart';

// ── Gelesenes Buch erfassen ──────────────────────────────────────────────────

Future<void> logReadViaSearch(BuildContext context) async {
  final book = await Navigator.push<Book>(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
  );
  if (book == null || !context.mounted) return;
  await _logAndConfirm(context, book);
}

Future<void> logReadViaScanner(BuildContext context) async {
  final isbn = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );
  if (isbn == null || !context.mounted) return;

  try {
    final book = await BookApiService().searchByIsbn(isbn);
    if (!context.mounted) return;
    if (book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No results for ISBN $isbn')),
      );
      return;
    }
    await _logAndConfirm(context, book);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

Future<void> logReadFromWishlist(BuildContext context) async {
  final entry = await Navigator.push<BookEntry>(
    context,
    MaterialPageRoute(builder: (_) => const WishlistScreen(pickMode: true)),
  );
  if (entry == null || !context.mounted) return;

  await bookRepository.logBookAsReadFromEntry(entry);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${entry.title}" logged as read')),
  );
}

Future<void> _logAndConfirm(BuildContext context, Book book) async {
  await bookRepository.logBookAsRead(book);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${book.title}" logged as read')),
  );
}

void showLogReadOptions(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan ISBN'),
            onTap: () {
              Navigator.pop(dialogContext);
              logReadViaScanner(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search book'),
            onTap: () {
              Navigator.pop(dialogContext);
              logReadViaSearch(context);
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.checklist),
          //   title: const Text('From wishlist'),
          //   onTap: () {
          //     Navigator.pop(dialogContext);
          //     logReadFromWishlist(context);
          //   },
          // ),
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

// ── Buch hinzufügen ──────────────────────────────────────────────────────────

Future<void> addToWishlistViaSearch(BuildContext context) async {
  final book = await Navigator.push<Book>(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
  );
  if (book == null || !context.mounted) return;

  await bookRepository.addToWishlist(book);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${book.title}" added to wishlist')),
  );
}

Future<void> addToShelfViaSearch(BuildContext context) async {
  final book = await Navigator.push<Book>(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
  );
  if (book == null || !context.mounted) return;

  await bookRepository.addToShelf(book);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${book.title}" added to shelf')),
  );
}

Future<void> addToShelfViaScanner(BuildContext context) async {
  final isbn = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => const ScannerScreen()),
  );
  if (isbn == null || !context.mounted) return;

  try {
    final book = await BookApiService().searchByIsbn(isbn);
    if (!context.mounted) return;
    if (book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No results for ISBN $isbn')),
      );
      return;
    }
    await bookRepository.addToShelf(book);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${book.title}" added to shelf')),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

void showAddOptions(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Add book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('To Wishlist'),
            onTap: () {
              Navigator.pop(dialogContext);
              addToWishlistViaSearch(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shelves),
            title: const Text('To Shelf'),
            subtitle: const Text('Search or Scan'),
            onTap: () {
              Navigator.pop(dialogContext);
              _showAddToShelfOptions(context);
            },
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

void _showAddToShelfOptions(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('To Shelf'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan ISBN'),
            onTap: () {
              Navigator.pop(dialogContext);
              addToShelfViaScanner(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search book'),
            onTap: () {
              Navigator.pop(dialogContext);
              addToShelfViaSearch(context);
            },
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
