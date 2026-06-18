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

  Future<void> _showAddCategoryDialog(BuildContext context, int bookId) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _CategoryEditorDialog(bookId: bookId),
    );
  }

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
                onPressed: () =>
                    bookRepository.setFavorite(book.id, !book.isFavorite),
                icon: Icon(
                  book.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: book.isFavorite
                    ? Theme.of(context).colorScheme.primary
                    : null,
                tooltip: book.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
              ),
              IconButton(
                onPressed: () async {
                  final confirmed = await confirmDialog(
                    context,
                    title: 'Delete book?',
                    message: '"${book.title}" will be removed from your shelf.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (!confirmed || !context.mounted) return;
                  await bookRepository.delete(book.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete book',
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
                          height: 240,
                          placeholder: (_, __) => const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (_, __, ___) =>
                              const Icon(Icons.menu_book_rounded, size: 120),
                        )
                      : const Icon(Icons.menu_book_rounded, size: 120),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${book.author}'
                    '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rating',
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
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Status'),
                  subtitle: Text(book.keepBook ? 'Keep' : 'For sale'),
                  secondary: Icon(
                    book.keepBook ? Icons.shelves : Icons.sell_outlined,
                  ),
                  value: book.keepBook,
                  onChanged: (newValue) {
                    bookRepository.setKeep(book.id, newValue);
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                StreamBuilder(
                  stream: bookRepository.watchCategoriesForBook(book.id),
                  builder: (context, catSnapshot) {
                    final categories = catSnapshot.data ?? [];
                    return Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ...categories.map(
                          (cat) => Chip(
                            label: Text(cat.name),
                            onDeleted: () {
                              bookRepository.removeCategoryFromBook(
                                book.id,
                                cat.id,
                              );
                            },
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          onPressed: () =>
                              _showAddCategoryDialog(context, book.id),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Added on ${DateFormat('MM/dd/yyyy').format(book.addedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      title: const Text('Categories'),
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
                    hintText: 'Search or create new',
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
                              title: Text('Create "${_query.trim()}"'),
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
                              child: Text('No more categories.'),
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
          child: const Text('Done'),
        ),
      ],
    );
  }
}
