import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../models/book.dart';

class SearchPreviewScreen extends StatelessWidget {
  final Book book;

  const SearchPreviewScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = book.title ?? l10n.noTitle;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.add,
            onPressed: () => Navigator.pop(context, book),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: book.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl!,
                      height: 220,
                      placeholder: (_, __) => const SizedBox(
                        height: 220,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.menu_book_rounded, size: 100),
                    )
                  : const Icon(Icons.menu_book_rounded, size: 100),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: Text(
                '${book.author ?? l10n.unknown}'
                '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            Builder(builder: (context) {
              final hasDescription = book.description?.isNotEmpty == true;
              return Text(
                hasDescription ? book.description! : l10n.noDescrAvailable,
                style: hasDescription
                    ? const TextStyle(fontSize: 14, height: 1.5)
                    : const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5),
              );
            }),
          ],
        ),
      ),
    );
  }
}
