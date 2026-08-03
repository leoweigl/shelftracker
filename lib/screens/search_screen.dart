import 'package:flutter/material.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'search_preview_screen.dart';

class SearchScreen extends StatefulWidget {
  /// Called when the user picks a book to add. Should perform (or let the
  /// user cancel) the save and return true if the book was saved. Returning
  /// true closes the search screen; returning false keeps the results
  /// visible so another book can be picked.
  final Future<bool> Function(BuildContext context, Book book) onAddBook;

  const SearchScreen({super.key, required this.onAddBook});

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

    if (query.trim().length < 3) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 600), _search);
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isIsbn = RegExp(r'^\d{10}(\d{3})?$').hasMatch(query);
      if (isIsbn) {
        final book = await _apiService.searchByIsbn(query);
        setState(() {
          _results = book != null ? [book] : [];
          _isLoading = false;
        });
        return;
      }

      final results = await _apiService.search(query);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${AppLocalizations.of(context)!.searchError} $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.searchBook),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterTitleAuthorIsbn,
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final book = _results[index];
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 16, right: 8),
                  horizontalTitleGap: 8,
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
                            const Icon(Icons.menu_book_rounded),
                      )
                    : const Icon(Icons.menu_book_rounded),
                  title: Text(
                    book.title ?? AppLocalizations.of(context)!.noTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${book.author ?? AppLocalizations.of(context)!.unknown}'
                    '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: AppLocalizations.of(context)!.add,
                    onPressed: () async {
                      final added = await widget.onAddBook(context, book);
                      if (added && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  onTap: () async {
                    final added = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchPreviewScreen(
                          book: book,
                          onAddBook: widget.onAddBook,
                        ),
                      ),
                    );
                    if (added == true && context.mounted) {
                      Navigator.pop(context);
                    }
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