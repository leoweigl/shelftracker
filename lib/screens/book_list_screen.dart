import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../models/book.dart';
import '../widgets/star_rating.dart';
import 'search_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  Future<void> _openSearch() async {
    final selectedBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );

    if (selectedBook != null) {
      await bookRepository.insertFromBook(selectedBook);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bücherregal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: StreamBuilder<List<BookEntry>>(
        stream: bookRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Noch keine Bücher.\nTippe oben rechts auf +',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: book.coverUrl != null
                    ? Image.network(
                  book.coverUrl!,
                  width: 40,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.menu_book_rounded),
                )
                    : const Icon(Icons.menu_book_rounded),
                title: Text(book.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${book.author}'
                          '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                    ),
                    const SizedBox(height: 4),
                    book.userRating == null
                        ? const Text('noch nicht bewertet')
                        : StarRating(rating: book.userRating!),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => bookRepository.delete(book.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}