import 'package:flutter/material.dart';
import 'package:shelftracker/services/book_api_service.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../models/book.dart';
import '../widgets/star_rating.dart';
import 'search_screen.dart';
import 'book_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'scanner_screen.dart';
import '../models/book_sort.dart';
import '../utils/dialogs.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  BookSort _sort = BookSort.title;
  bool _ascending = true;

  Future<void> _openSearch() async {
    final selectedBook = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );

    if (selectedBook == null || !mounted) return;

    final id = await bookRepository.insertFromBook(selectedBook);

    if (!mounted) return;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${selectedBook.title}" ist schon im Regal')),
      );
    }
  }

  Future<void> _openScanner() async {
    final isbn = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );

    if (isbn == null || !mounted) return;

    try {
      final book = await BookApiService().searchByIsbn(isbn);

      if (!mounted) return;

      if (book == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Keine Treffer für ISBN $isbn')));
        return;
      }

      final id = await bookRepository.insertFromBook(book);

      if (!mounted) return;
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.title}" ist schon im Regal')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('"${book.title}" hinzugefügt')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _openScanner,
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: _openSearch),
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
                      message: '"${book.title}" wird endgültig aus deinem Regal entfernt.',
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
