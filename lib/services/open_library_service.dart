import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class OpenLibraryService {
  static const String _baseUrl = 'https://openlibrary.org';

  static const Map<String, String> _headers = {
    'User-Agent': 'ShelfTracker/1.0 (leonhard@weigl.dev)',
  };

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}'
      '&limit=20'
      '&fields=key,title,author_name,first_publish_year,cover_i,subject',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Open Library: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List;

    return docs
        .map((doc) => Book.fromOpenLibrary(doc as Map<String, dynamic>))
        .toList();
  }

  Future<Book?> searchByIsbn(String isbn) async {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
    if (cleanIsbn.isEmpty) return null;

    final url = Uri.parse(
      '$_baseUrl/search.json?q=isbn:$cleanIsbn'
      '&limit=1'
      '&fields=key,title,author_name,first_publish_year,cover_i,subject',
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Open Library: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List;

    if (docs.isEmpty) return null;

    return Book.fromOpenLibrary(docs.first as Map<String, dynamic>);
  }
}