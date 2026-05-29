import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';

  static const String _apiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
    defaultValue: '',
  );

  String _withKey(String url) {
    if (_apiKey.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}key=$_apiKey';
  }

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(_withKey(
      '$_baseUrl/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=20',
    ));

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Google Books: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List?;

    if (items == null || items.isEmpty) return [];

    return items
        .map((item) => Book.fromGoogleBooks(item as Map<String, dynamic>))
        .toList();
  }

  Future<Book?> searchByIsbn(String isbn) async {
    final cleanIsbn = isbn.replaceAll(RegExp(r'[^0-9X]'), '');
    if (cleanIsbn.isEmpty) return null;

    final url = Uri.parse(_withKey(
      '$_baseUrl/volumes?q=isbn:$cleanIsbn&maxResults=1',
    ));

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Google Books: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List?;

    if (items == null || items.isEmpty) return null;

    return Book.fromGoogleBooks(items.first as Map<String, dynamic>);
  }
}