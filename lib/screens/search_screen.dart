import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    ? Image.network(
                        book.coverUrl!,
                        width: 40,
                        errorBuilder: (_, __, ___) =>
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