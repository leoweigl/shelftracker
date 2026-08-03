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
import '../utils/searchable_list_state.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen>
    with SearchableListState<BookListScreen> {
  BookSort _sort = BookSort.addedAt;
  bool _ascending = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookshelf),
        actions: [
          buildSearchAction(context),
          PopupMenuButton<BookSort>(
            icon: const Icon(Icons.sort),
            tooltip: AppLocalizations.of(context)!.sort,
            initialValue: _sort,
            onSelected: (value) => _updateSort(value, _ascending),
            itemBuilder: (_) => BookSort.values
                .map(
                  (s) => PopupMenuItem(value: s, child: Text(s.label(context))),
                )
                .toList(),
          ),
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending
                ? AppLocalizations.of(context)!.asc
                : AppLocalizations.of(context)!.desc,
            onPressed: () => _updateSort(_sort, !_ascending),
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchField(context),
          Expanded(
            child: StreamBuilder<List<BookEntry>>(
              stream: _bookStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data ?? [];

                final filteredBooks = filterBySearch(books);

                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? AppLocalizations.of(context)!.noBooksYet
                          : AppLocalizations.of(context)!.noBooksMatch,
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ),
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
                        title: Text(
                          book.title.isEmpty
                              ? AppLocalizations.of(context)!.noTitle
                              : book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
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
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.favorite,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
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
                                    ? Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.notYetRated,
                                      )
                                    : StarRating(rating: book.userRating!),
                                const Spacer(),
                                if (!book.keepBook)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
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
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!.forSale,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
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
                        trailing: _BookActions(book: book),
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

enum _BookAction { logAsRead, delete }

class _BookActions extends StatelessWidget {
  final BookEntry book;

  const _BookActions({required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;
    return PopupMenuButton<_BookAction>(
      icon: const Icon(Icons.more_vert, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _BookAction.logAsRead,
          child: ListTile(
            leading: const Icon(Icons.done_all),
            title: Text(l10n.logAsRead),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _BookAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: errorColor),
            title: Text(l10n.delete, style: TextStyle(color: errorColor)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, _BookAction action) async {
    final l10n = AppLocalizations.of(context)!;
    final title = book.title.isEmpty ? l10n.noTitle : book.title;

    switch (action) {
      case _BookAction.logAsRead:
        await bookRepository.logBookAsReadFromEntry(book);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$title" ${l10n.loggedAsRead}')),
        );

      case _BookAction.delete:
        final confirmed = await confirmDialog(
          context,
          title: l10n.askDeleteBook,
          message: '"$title" ${l10n.confirmDelete}',
          confirmLabel: l10n.delete,
          isDestructive: true,
        );
        if (!confirmed) return;
        await bookRepository.delete(book.id);
    }
  }
}
