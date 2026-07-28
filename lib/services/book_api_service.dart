import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';

class BookApiService {
  final OpenLibraryService _openLibrary = OpenLibraryService();
  final GoogleBooksService _googleBooks = GoogleBooksService();

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final results = await Future.wait([
      _googleBooks.search(query).catchError((e) {
        debugPrint('Google Books search failed: $e');
        return <Book>[];
      }),
      _openLibrary.search(query).catchError((e) {
        debugPrint('OpenLibrary search failed: $e');
        return <Book>[];
      }),
    ]);

    final googleResults = results[0];
    final openLibraryResults = results[1];

    debugPrint(
      'Google Books: ${googleResults.length} Treffer, '
      'OpenLibrary: ${openLibraryResults.length} Treffer',
    );

    return _mergeAndDedupe(googleResults, openLibraryResults);
  }

  List<Book> _mergeAndDedupe(
    List<Book> googleResults,
    List<Book> openLibraryResults,
  ) {
    final merged = <String, Book>{};

    for (final book in googleResults) {
      merged[_dedupeKey(book)] = book;
    }

    for (final book in openLibraryResults) {
      merged.putIfAbsent(_dedupeKey(book), () => book);
    }

    return merged.values.toList();
  }

  String _dedupeKey(Book book) {
    final title = (book.title ?? '').toLowerCase().trim();
    final author = (book.author ?? '').toLowerCase().trim();
    return '$title|$author';
  }

  Future<Book?> searchByIsbn(String isbn) async {
    final results = await Future.wait([
      _googleBooks.searchByIsbn(isbn).catchError((e) {
        debugPrint('Google Books ISBN search failed: $e');
        return null;
      }),
      _openLibrary.searchByIsbn(isbn).catchError((e) {
        debugPrint('OpenLibrary ISBN search failed: $e');
        return null;
      }),
    ]);

    return results[0] ?? results[1];
  }
}
