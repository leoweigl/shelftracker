import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _apiService = BookApiService();

  List<Book> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), _search);
  }

  Future<void> _search() async {
    final query = _controller.text;
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _apiService.search(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Suche: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buch suchen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Titel oder Autor eingeben...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final book = _results[index];
                return ListTile(
                  leading: book.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        width: 40,
                        placeholder: (_, __) => const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.book),
                      )
                    : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author}'
                    '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                  ),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    Navigator.pop(context, book);
                  },
                );
              },
            )
          )
        ],
      ),
    );
  }
}