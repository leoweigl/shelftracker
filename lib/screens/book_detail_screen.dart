import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';

class BookDetailScreen extends StatelessWidget {
  final int bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: bookRepository.watchById(bookId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final book = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            actions: [
              IconButton(
                  onPressed: () async {
                    final confirmed = await confirmDialog(
                      context,
                      title: 'Buch löschen?',
                      message: '"${book.title}" wird engültig aus deinem Regal entfernt.',
                      confirmLabel: 'Löschen',
                      isDestructive: true,
                    );
                    if (!confirmed || !context.mounted) return;
                    await bookRepository.delete(book.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Buch löschen',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                book.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.coverUrl!,
                        height: 240,
                        placeholder: (_, __) => const SizedBox(
                          height: 240,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.menu_book_rounded, size: 120),
                      )
                    : const Icon(Icons.menu_book_rounded, size: 120),

                const SizedBox(height: 16),

                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  '${book.author}'
                  '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Bewertung',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                StarRating(
                  rating: book.userRating ?? 0,
                  size: 36,
                  onRatingChanged: (newRating) {
                    bookRepository.updateRating(book.id, newRating);
                  },
                ),

                const SizedBox(height: 24),

                SwitchListTile(
                  title: const Text('Status'),
                  subtitle: Text(book.keepBook ? 'Behalten' : 'Verkaufen'),
                  secondary: Icon(
                    book.keepBook
                        ? Icons.bookmarks
                        : Icons.monetization_on_outlined,
                  ),
                  value: book.keepBook,
                  onChanged: (newValue) {
                    bookRepository.setKeep(book.id, newValue);
                  },
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hinzugefügt am ${DateFormat('dd.MM.yyyy').format(book.addedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
