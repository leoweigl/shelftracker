import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          appBar: AppBar(title: Text(book.title)),
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

                Text(
                  'Bewertung',
                  style: Theme.of(context).textTheme.titleSmall,
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
                  title: const Text('Behalten'),
                  subtitle: Text(book.keepBook ? 'Behalten' : 'Verkaufen'),
                  value: book.keepBook,
                  onChanged: (newValue) {
                    bookRepository.setKeep(book.id, newValue);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
