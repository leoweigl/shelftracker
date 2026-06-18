import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shelftracker/screens/log_detail_screen.dart';
import '../main.dart';
import '../database/book_repository.dart';
import '../widgets/star_rating.dart';
import '../utils/book_actions.dart';

class ReadingLogScreen extends StatelessWidget {
  const ReadingLogScreen({super.key});

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
      helpText: 'Change read date',
    );
    if (picked == null) return;
    await bookRepository.updateReadDate(logId, picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_added_outlined),
            tooltip: 'Log read book',
            onPressed: () => showLogReadOptions(context),
          ),
        ],
      ),
      body: StreamBuilder<List<ReadingLogItem>>(
        stream: bookRepository.watchReadingLog(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('No read books logged yet.'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 8,
              indent: 72,
              endIndent: 16,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final entry = item.entry;

              return ListTile(
                leading: entry.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: entry.coverUrl!,
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
                title: Text(entry.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(child: Text(entry.author)),
                        if (item.isFavorite) _favoritePill(context),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        item.userRating == null
                            ? const Text('not yet rated')
                            : StarRating(rating: item.userRating!),
                        const Spacer(),
                        if (!item.inShelf) _notOwnedPill(context),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () =>
                          _editReadDate(context, entry.id, entry.readDate),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Read on '
                            '${DateFormat('MM/dd/yyyy').format(entry.readDate)}',
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LogDetailScreen(logId: entry.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _favoritePill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite,
            size: 12,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Favorite',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notOwnedPill(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'not in shelf',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
