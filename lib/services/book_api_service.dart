import '../models/book.dart';
import 'open_library_service.dart';
import 'google_books_service.dart';

class BookApiService {
  final OpenLibraryService _openLibrary = OpenLibraryService();
  final GoogleBooksService _googleBooks = GoogleBooksService();

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _openLibrary.search(query);
      if (results.isNotEmpty) return results;
    } catch (_) {}

    try {
      return await _googleBooks.search(query);
    } catch (_) {
      return [];
    }
  }

  Future<Book?> searchByIsbn(String isbn) async {
    try {
      final book = await _openLibrary.searchByIsbn(isbn);
      if (book != null) return book;
    } catch (_) {}

    try {
      final book = await _googleBooks.searchByIsbn(isbn);
      return book;
    } catch (_) {
      return null;
    }
  }
}
