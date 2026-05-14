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
}