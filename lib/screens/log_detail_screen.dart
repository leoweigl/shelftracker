import 'package:flutter/material.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';

class LogDetailScreen extends StatelessWidget {
  final int logId;

  const LogDetailScreen({super.key, required this.logId});

  Future<void> _editReadDate(
    BuildContext context,
    int logId,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: AppLocalizations.of(context)!.changeReadDate,
    );
    if (picked == null) return;
    await bookRepository.updateReadDate(logId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<ReadingLogEntry>(
      stream: bookRepository.watchReadingLogById(logId),
      builder: (context, logSnapshot) {
        if (!logSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final entry = logSnapshot.data!;

        return StreamBuilder<BookEntry?>(
          stream: entry.bookId != null
              ? bookRepository.watchById(entry.bookId!)
              : Stream.value(null),
          builder: (context, bookSnapshot) {
            final book = bookSnapshot.data;
            final isFavorite = book?.isFavorite ?? false;

            return Scaffold(
              appBar: AppBar(
                title: Text(entry.title.isEmpty ? l10n.noTitle : entry.title),
                actions: [
                  IconButton(
                    onPressed: () {
                      if (book != null && entry.bookId != null) {
                        bookRepository.setFavorite(entry.bookId!, !isFavorite);
                      }
                    },

                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    tooltip: isFavorite
                        ? l10n.detailRemoveFav
                        : l10n.detailAddFav,
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await confirmDialog(
                        context,
                        title: l10n.askDeleteLog,
                        message:
                            l10n.confirmDeleteLog,
                        confirmLabel: l10n.remove,
                        isDestructive: true,
                      );
                      if (!confirmed || !context.mounted) return;
                      await bookRepository.deleteLogEntry(logId);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.deleteLog,
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: entry.coverUrl != null
                          ? CachedNetworkImage(
                              imageUrl: entry.coverUrl!,
                              height: 240,
                              placeholder: (_, __) => const SizedBox(
                                height: 240,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.menu_book_rounded,
                                size: 120,
                              ),
                            )
                          : const Icon(Icons.menu_book_rounded, size: 120),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        entry.title.isEmpty ? l10n.noTitle : entry.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '${entry.author}'
                        '${book?.publicationYear != null ? ' • ${book?.publicationYear}' : ''}',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (book != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.rating,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),

                      StarRating(
                        rating: book.userRating ?? 0,
                        size: 36,
                        onRatingChanged: (newRating) {
                          if (entry.bookId != null) {
                            bookRepository.updateRating(
                              entry.bookId!,
                              newRating,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                    ],

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.readOn} '
                          '${DateFormat(l10n.dateFormat).format(entry.readDate)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 24),
                          color: Theme.of(context).colorScheme.outline,
                          onPressed: () =>
                              _editReadDate(context, entry.id, entry.readDate),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
