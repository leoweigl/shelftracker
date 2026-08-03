import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../models/book_status.dart';
import 'book_detail_screen.dart';
import '../utils/dialogs.dart';
import '../utils/searchable_list_state.dart';

class WishlistScreen extends StatefulWidget {
  final bool pickMode;

  const WishlistScreen({super.key, this.pickMode = false});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SearchableListState<WishlistScreen> {
  BookStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? l10n.selectBook : l10n.wishlist),
        actions: [buildSearchAction(context)],
      ),
      body: Column(
        children: [
          buildSearchField(context),
          _FilterPills(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: StreamBuilder<List<BookEntry>>(
              stream: bookRepository.watchWishlist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snapshot.data ?? [];
                final statusFiltered = _filter == null
                    ? all
                    : all.where((b) => b.status == _filter!.name).toList();
                final books = filterBySearch(statusFiltered);

                if (books.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noFilteredBooks(_filter?.name ?? 'all'),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _WishlistTile(
                        book: book,
                        pickMode: widget.pickMode,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPills extends StatelessWidget {
  final BookStatus? selected;
  final ValueChanged<BookStatus?> onChanged;

  const _FilterPills({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    Widget pill(String label, BookStatus? value) {
      final isSelected = selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          labelStyle: TextStyle(
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(isSelected ? null : value),
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          pill(l10n.all, null),
          pill(l10n.statusWishlisted, BookStatus.wishlist),
          pill(l10n.statusPreordered, BookStatus.preordered),
        ],
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final BookEntry book;
  final bool pickMode;

  const _WishlistTile({required this.book, required this.pickMode});

  @override
  Widget build(BuildContext context) {
    final status = BookStatus.fromDb(book.status);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: book.coverUrl != null
          ? CachedNetworkImage(
              imageUrl: book.coverUrl!,
              width: 40,
              placeholder: (ctx, url) => const SizedBox(
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
              errorWidget: (ctx, url, err) =>
                  const Icon(Icons.menu_book_rounded),
            )
          : const Icon(Icons.menu_book_rounded),
      title: Text(
        book.title.isEmpty ? l10n.noTitle : book.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${book.author.isEmpty ? l10n.unknown : book.author}'
              '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status == BookStatus.preordered) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.statusPreordered,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      horizontalTitleGap: 8,
      trailing: pickMode ? null : _WishlistActions(book: book, status: status),
      onTap: pickMode
          ? () => Navigator.pop(context, book)
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookDetailScreen(bookId: book.id),
              ),
            ),
    );
  }
}

class _WishlistActions extends StatelessWidget {
  final BookEntry book;
  final BookStatus status;

  const _WishlistActions({required this.book, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;
    return PopupMenuButton<_WishlistAction>(
      icon: const Icon(Icons.more_vert, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _WishlistAction.moveToShelf,
          child: ListTile(
            leading: Icon(Icons.shelves),
            title: Text(l10n.moveToShelf),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _WishlistAction.logAsRead,
          child: ListTile(
            leading: Icon(Icons.done_all),
            title: Text(l10n.logAsRead),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (status == BookStatus.wishlist)
          PopupMenuItem(
            value: _WishlistAction.markAsPreordered,
            child: ListTile(
              leading: Icon(Icons.schedule),
              title: Text(l10n.markAsPreordered),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (status == BookStatus.preordered)
          PopupMenuItem(
            value: _WishlistAction.removePreorder,
            child: ListTile(
              leading: Icon(Icons.undo),
              title: Text(l10n.removePreorder),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        PopupMenuItem(
          value: _WishlistAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: errorColor),
            title: Text(l10n.delete, style: TextStyle(color: errorColor)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _WishlistAction action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case _WishlistAction.moveToShelf:
        await bookRepository.setStatus(book.id, BookStatus.owned);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.movedToShelf}',
            ),
          ),
        );

      case _WishlistAction.logAsRead:
        await bookRepository.logBookAsReadFromEntry(book);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.loggedAsRead}',
            ),
          ),
        );

      case _WishlistAction.markAsPreordered:
        await bookRepository.setStatus(book.id, BookStatus.preordered);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.markedAsPreordered}',
            ),
          ),
        );

      case _WishlistAction.removePreorder:
        await bookRepository.setStatus(book.id, BookStatus.wishlist);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.removedPreorder} "${book.title.isEmpty ? l10n.noTitle : book.title}"',
            ),
          ),
        );

      case _WishlistAction.delete:
        final title = book.title.isEmpty ? l10n.noTitle : book.title;
        final confirmed = await confirmDialog(
          context,
          title: l10n.askDeleteBook,
          message: '"$title" ${l10n.confirmDeleteWishlist}',
          confirmLabel: l10n.delete,
          isDestructive: true,
        );
        if (!confirmed) return;
        await bookRepository.delete(book.id);
    }
  }
}

enum _WishlistAction {
  moveToShelf,
  logAsRead,
  markAsPreordered,
  removePreorder,
  delete,
}
