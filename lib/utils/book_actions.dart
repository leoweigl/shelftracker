import 'package:flutter/material.dart';
import '../main.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';
import '../screens/search_screen.dart';
import '../screens/scanner_screen.dart';

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
        SnackBar(content: Text('Keine Treffer für ISBN $isbn')),
      );
      return;
    }
    await _logAndConfirm(context, book);
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fehler: $e')),
    );
  }
}

Future<void> _logAndConfirm(BuildContext context, Book book) async {
  await bookRepository.logBookAsRead(book);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('"${book.title}" als gelesen erfasst')),
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
            title: const Text('ISBN scannen'),
            onTap: () {
              Navigator.pop(dialogContext);
              logReadViaScanner(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Buch suchen'),
            onTap: () {
              Navigator.pop(dialogContext);
              logReadViaSearch(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Abbrechen'),
        ),
      ],
    ),
  );
}