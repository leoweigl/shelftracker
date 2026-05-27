import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const String _baseUrl = 'https://openlibrary.org';

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('API-Fehler: ${response.statusCode}');
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
      '$_baseUrl/search.json?q=isbn:$cleanIsbn&limit=1',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('API-Fehler: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List;
    
    if (docs.isEmpty) return null;
    
    return Book.fromOpenLibrary(docs.first as Map<String, dynamic>);
  }
}