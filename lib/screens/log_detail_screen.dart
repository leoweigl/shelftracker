import 'dart:ffi';

import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';
import 'reading_log_screen.dart';

class LogDetailScreen extends StatelessWidget {
  final int logId;

  const LogDetailScreen({super.key, required this.logId});

  Future<void> _showAddCategoryDialog(BuildContext context, int bookId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CategoryEditorDialog(bookId: bookId),
    );
  }

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
      helpText: 'Lesedatum ändern',
    );
    if (picked == null) return;
    await bookRepository.updateReadDate(logId, picked);
  }

  @override
  Widget build(BuildContext context) {
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
            final keepBook = book?.keepBook ?? true;
            final addedAt = book?.addedAt;

            return Scaffold(
              appBar: AppBar(
                title: Text(entry.title),
                actions: [
                  IconButton(
                    onPressed: () =>
                        bookRepository.setFavorite(entry.bookId!, !isFavorite),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                    color: book?.isFavorite ?? false
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    tooltip: isFavorite
                        ? 'Aus Favoriten entfernen'
                        : 'Zu Favoriten hinzufügen',
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await confirmDialog(
                        context,
                        title: 'Eintrag löschen?',
                        message:
                            'Dieser Leseeintrag wird endgültig aus dem Protokoll entfernt.',
                        confirmLabel: 'Entfernen',
                        isDestructive: true,
                      );
                      if (!confirmed || !context.mounted) return;
                      await bookRepository.deleteLogEntry(logId);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Eintrag löschen',
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
                        entry.title,
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

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bewertung',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StarRating(
                      rating: book?.userRating ?? 0,
                      size: 36,
                      onRatingChanged: (newRating) {
                        bookRepository.updateRating(entry.bookId!, newRating);
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Gelesen am '
                          '${DateFormat('dd.MM.yyyy').format(entry.readDate)}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 24),
                          color: Theme.of(context).colorScheme.outline,
                          onPressed: () => _editReadDate(context, entry.id, entry.readDate),
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

class _CategoryEditorDialog extends StatefulWidget {
  final int bookId;
  const _CategoryEditorDialog({required this.bookId});

  @override
  State<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<_CategoryEditorDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createAndAdd(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = await bookRepository.getOrCreateCategory(trimmed);
    await bookRepository.addCategoryToBook(widget.bookId, id);
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kategorien'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<CategoryEntry>>(
          stream: bookRepository.watchCategoriesForBook(widget.bookId),
          builder: (context, assignedSnapshot) {
            final assigned = assignedSnapshot.data ?? [];
            final assignedIds = assigned.map((c) => c.id).toSet();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assigned.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: assigned
                        .map(
                          (cat) => Chip(
                            label: Text(cat.name),
                            onDeleted: () => bookRepository
                                .removeCategoryFromBook(widget.bookId, cat.id),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Suchen oder neu anlegen',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 12),

                StreamBuilder<List<CategoryEntry>>(
                  stream: bookRepository.watchCategories(),
                  builder: (context, allSnapshot) {
                    final all = allSnapshot.data ?? [];
                    final q = _query.trim().toLowerCase();

                    final available = all
                        .where((c) => !assignedIds.contains(c.id))
                        .where((c) => c.name.toLowerCase().contains(q))
                        .toList();

                    final exactExists = all.any(
                      (c) => c.name.toLowerCase() == q,
                    );

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          if (q.isNotEmpty && !exactExists)
                            ListTile(
                              leading: const Icon(Icons.add),
                              title: Text('"${_query.trim()}" anlegen'),
                              onTap: () => _createAndAdd(_query),
                            ),
                          ...available.map(
                            (cat) => ListTile(
                              title: Text(cat.name),
                              onTap: () => bookRepository.addCategoryToBook(
                                widget.bookId,
                                cat.id,
                              ),
                            ),
                          ),
                          if (available.isEmpty && (q.isEmpty || exactExists))
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text('Keine weiteren Kategorien.'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fertig'),
        ),
      ],
    );
  }
}
