import 'package:flutter/material.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import 'package:shelftracker/utils/dialogs.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'book_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_sort.dart';
import '../models/book_status.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  BookSort _sort = BookSort.addedAt;
  bool _ascending = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  late Stream<List<BookEntry>> _bookStream;

  @override
  void initState() {
    super.initState();
    _bookStream = bookRepository.watchAll(
      sort: _sort,
      ascending: _ascending,
      status: BookStatus.owned,
    );
  }

  void _updateSort(BookSort sort, bool ascending) {
    setState(() {
      _sort = sort;
      _ascending = ascending;
      _bookStream = bookRepository.watchAll(
        sort: sort,
        ascending: ascending,
        status: BookStatus.owned,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookshelf),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? AppLocalizations.of(context)!.closeSearch : AppLocalizations.of(context)!.search,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          PopupMenuButton<BookSort>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sort,
            initialValue: _sort,
            onSelected: (value) => _updateSort(value, _ascending),
            itemBuilder: (_) => BookSort.values
                .map((s) => PopupMenuItem(value: s, child: Text(s.label(context))))
                .toList(),
          ),
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending ? AppLocalizations.of(context)!.asc : AppLocalizations.of(context)!.desc,
            onPressed: () => _updateSort(_sort, !_ascending),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchTitleOrAuthor,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),
            ),
          Expanded(
            child: StreamBuilder<List<BookEntry>>(
              stream: _bookStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data ?? [];

                final filteredBooks = _searchQuery.isEmpty
                  ? books
                  : books.where((b) =>
                    b.title.toLowerCase().contains(_searchQuery) ||
                    b.author.toLowerCase().contains(_searchQuery)).toList();

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                        ? AppLocalizations.of(context)!.noBooksYet
                        : AppLocalizations.of(context)!.noBooksMatch,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredBooks.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 8,
                    indent: 72,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.menu_book_rounded),
                            )
                          : const Icon(Icons.menu_book_rounded),
                      title: Text(book.title.isEmpty ? AppLocalizations.of(context)!.noTitle : book.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${book.author.isEmpty ? AppLocalizations.of(context)!.unknown : book.author}'
                                '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                              ),
                              const Spacer(),
                              if (book.isFavorite)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.of(context)!.favorite,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              book.userRating == null
                                  ? Text(AppLocalizations.of(context)!.notYetRated)
                                  : StarRating(rating: book.userRating!),
                              const Spacer(),
                              if (!book.keepBook)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.sell_outlined,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.of(context)!.forSale,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(bookId: book.id),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirmed = await confirmDialog(
                            context,
                            title: AppLocalizations.of(context)!.askDeleteBook,
                            message:
                                '"${book.title.isEmpty ? AppLocalizations.of(context)!.noTitle : book.title}" ${AppLocalizations.of(context)!.confirmDelete}',
                            confirmLabel: AppLocalizations.of(context)!.delete,
                            isDestructive: true,
                          );
                          if (!confirmed) return;
                          await bookRepository.delete(book.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
