import '../models/book.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';

class BookApiService {
  final OpenLibraryService _openLibrary = OpenLibraryService();
  final GoogleBooksService _googleBooks = GoogleBooksService();

  // Future<List<Book>> search(String query) async {
  //   if (query.trim().isEmpty) return [];
  //
  //   try {
  //     final results = await _googleBooks.search(query);
  //     if (results.isNotEmpty) return results;
  //   } catch (_) {}
  //
  //   try {
  //     return await _openLibrary.search(query);
  //   } catch (_) {
  //     return [];
  //   }
  // }

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _googleBooks.search(query);
      if (results.isNotEmpty) {
        print('[DEBUG] Google Books: ${results.length} Treffer für "$query"');
        print('[DEBUG] Erstes Ergebnis "${results.first.title}" — description: ${results.first.description == null ? "NULL" : "${results.first.description!.length} Zeichen"}');
        return results;
      }
      print('[DEBUG] Google Books: leeres Ergebnis für "$query"');
    } catch (e) {
      print('[DEBUG] Google Books Fehler: $e');
    }

    print('[DEBUG] Fallback auf Open Library für "$query"');
    try {
      return await _openLibrary.search(query);
    } catch (e) {
      print('[DEBUG] Open Library Fehler: $e');
      return [];
    }
  }

  Future<Book?> searchByIsbn(String isbn) async {
    try {
      final book = await _googleBooks.searchByIsbn(isbn);
      if (book != null) return book;
    } catch (_) {}

    try {
      final book = await _openLibrary.searchByIsbn(isbn);
      return book;
    } catch (_) {
      return null;
    }
  }
}
