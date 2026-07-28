import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../models/book_status.dart';
import 'book_detail_screen.dart';
import '../utils/dialogs.dart';

class WishlistScreen extends StatefulWidget {
  final bool pickMode;

  const WishlistScreen({super.key, this.pickMode = false});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  BookStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? l10n.selectBook : l10n.wishlist),
      ),
      body: Column(
        children: [
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
                final books = _filter == null
                    ? all
                    : all.where((b) => b.status == _filter!.name).toList();

                if (books.isEmpty) {
                  return Center(
                    child: Text(l10n.noFilteredBooks(_filter?.name ?? 'all'),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: books.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 8,
                    indent: 72,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _WishlistTile(
                      book: book,
                      pickMode: widget.pickMode,
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
              errorWidget: (ctx, url, err) => const Icon(Icons.menu_book_rounded),
            )
          : const Icon(Icons.menu_book_rounded),
      title: Text(book.title.isEmpty ? l10n.noTitle : book.title),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${book.author.isEmpty ? l10n.unknown : book.author}'
            '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
          ),
          if (status == BookStatus.preordered) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.statusPreordered,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: pickMode
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.delete,
                  onPressed: () async {
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
                  },
                ),
                _WishlistActions(book: book, status: status),
              ],
            ),
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
    return PopupMenuButton<_WishlistAction>(
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
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, _WishlistAction action) async {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case _WishlistAction.moveToShelf:
        await bookRepository.setStatus(book.id, BookStatus.owned);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.movedToShelf}')),
        );

      case _WishlistAction.logAsRead:
        await bookRepository.logBookAsReadFromEntry(book);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.loggedAsRead}')),
        );

      case _WishlistAction.markAsPreordered:
        await bookRepository.setStatus(book.id, BookStatus.preordered);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${book.title.isEmpty ? l10n.noTitle : book.title}" ${l10n.markedAsPreordered}')),
        );

      case _WishlistAction.removePreorder:
        await bookRepository.setStatus(book.id, BookStatus.wishlist);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.removedPreorder} "${book.title.isEmpty ? l10n.noTitle : book.title}"')),
        );
    }
  }
}

enum _WishlistAction { moveToShelf, logAsRead, markAsPreordered, removePreorder}