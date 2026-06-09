import 'package:flutter/material.dart';
import 'package:shelftracker/utils/dialogs.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'book_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/book_sort.dart';
import '../utils/book_actions.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  BookSort _sort = BookSort.title;
  bool _ascending = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bücherregal'),
        actions: [
          PopupMenuButton<BookSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sortieren nach',
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (_) => BookSort.values
                .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                .toList(),
          ),
          IconButton(
            icon: Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: _ascending ? 'Aufsteigen' : 'Absteigend',
            onPressed: () => setState(() => _ascending = !_ascending),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            tooltip: 'Gelesenes Buch erfassen',
            onPressed: () => showLogReadOptions(context),
          ),
        ],
      ),
      body: StreamBuilder<List<BookEntry>>(
        stream: bookRepository.watchAll(sort: _sort, ascending: _ascending),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine Bücher.\nErfasse dein erstes gelesenes Buch oben rechts.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.separated(
            itemCount: books.length,
            separatorBuilder: (context, index) => Divider(
              height: 8,
              indent: 72,
              endIndent: 16,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final book = books[index];
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
                  const Icon(Icons.menu_book_rounded),
                )
                    : const Icon(Icons.menu_book_rounded),
                title: Text(book.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${book.author}'
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
                                  'Favorit',
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
                            ? const Text('noch nicht bewertet')
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
                                  'Verkaufen',
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
                      title: 'Buch löschen?',
                      message:
                          '"${book.title}" wird aus deinem Regal entfernt.',
                      confirmLabel: 'Löschen',
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
    );
  }
}
