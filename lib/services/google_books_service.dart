import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';

  static const String _apiKey = String.fromEnvironment(
    'GOOGLE_BOOKS_API_KEY',
    defaultValue: '',
  );

  static const _retryableStatusCodes = {429, 500, 503};
  static const _maxRetries = 2;
  static const _requestTimeout = Duration(seconds: 8);

  String _withKey(String url) {
    if (_apiKey.isEmpty) return url;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}key=$_apiKey';
  }

  Future<http.Response> _getWithRetry(Uri url) async {
    Object? lastError;

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await http.get(url).timeout(_requestTimeout);

        if (response.statusCode == 200) return response;

        if (!_retryableStatusCodes.contains(response.statusCode) ||
            attempt == _maxRetries) {
          throw Exception('Google Books: ${response.statusCode}');
        }

        lastError = Exception('Google Books: ${response.statusCode}');
      } catch (e) {
        lastError = e;
        if (attempt == _maxRetries) rethrow;
      }

      await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
    }

    throw lastError ?? Exception('Google Books: unknown error');
  }

  Future<List<Book>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(_withKey(
      '$_baseUrl/volumes?q=${Uri.encodeQueryComponent(query)}&maxResults=20',
    ));

    final response = await _getWithRetry(url);

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

    final response = await _getWithRetry(url);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List?;

    if (items == null || items.isEmpty) return null;

    return Book.fromGoogleBooks(items.first as Map<String, dynamic>);
  }
}