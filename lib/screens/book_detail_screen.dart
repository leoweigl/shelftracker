import 'package:flutter/material.dart';
import 'package:shelftracker/l10n/app_localizations.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/star_rating.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../utils/dialogs.dart';
import '../utils/book_actions.dart';
import '../models/book_status.dart';
import '../models/series_info.dart';
import '../services/hardcover_service.dart';

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
        final isOwned = BookStatus.fromDb(book.status) == BookStatus.owned;

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title.isEmpty ? AppLocalizations.of(context)!.noTitle : book.title),
            actions: [
              if (isOwned)
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
                      ? AppLocalizations.of(context)!.detailRemoveFav
                      : AppLocalizations.of(context)!.detailAddFav,
                ),
              IconButton(
                onPressed: () async {
                  final confirmed = await confirmDialog(
                    context,
                    title: AppLocalizations.of(context)!.askDeleteBook,
                    message: (book.title.isEmpty ? AppLocalizations.of(context)!.noTitle : book.title)
                        + AppLocalizations.of(context)!.confirmDelete,
                    confirmLabel: AppLocalizations.of(context)!.delete,
                    isDestructive: true,
                  );
                  if (!confirmed || !context.mounted) return;
                  await bookRepository.delete(book.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                tooltip: AppLocalizations.of(context)!.deleteBook,
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
                    book.title.isEmpty ? AppLocalizations.of(context)!.noTitle : book.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    '${book.author.isEmpty ? AppLocalizations.of(context)!.unknown : book.author}'
                    '${book.publicationYear != null ? ' • ${book.publicationYear}' : ''}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                if (isOwned) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.rating,
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
                    title: Text(AppLocalizations.of(context)!.status),
                    subtitle: Text(book.keepBook
                      ? AppLocalizations.of(context)!.keep
                      : AppLocalizations.of(context)!.forSale
                    ),
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
                    AppLocalizations.of(context)!.categories,
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
                              label: Text(AppLocalizations.of(context)!.add),
                              onPressed: () =>
                                  _showAddCategoryDialog(context, book.id),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                ],

                if (!isOwned && (book.description == null || book.description!.isEmpty)) ...[
                  Text(
                    AppLocalizations.of(context)!.noDescrAvailable,
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, height: 2),
                  ),
                  const SizedBox(height: 24),
                ],

                if (!isOwned && book.description != null && book.description!.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppLocalizations.of(context)!.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description!,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                ],

                _SeriesSection(book: book),

                Text(
                  '${AppLocalizations.of(context)!.addedOn}'
                  ' ${DateFormat(AppLocalizations.of(context)!.dateFormat).format(book.addedAt)}',
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
      title: Text(AppLocalizations.of(context)!.categories),
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
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchOrCreate,
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
                              title: Text('${AppLocalizations.of(context)!.createCategory} "${_query.trim()}"'),
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
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(AppLocalizations.of(context)!.noMoreCategories),
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
          child: Text(AppLocalizations.of(context)!.done),
        ),
      ],
    );
  }
}

class _SeriesSection extends StatefulWidget {
  final BookEntry book;

  const _SeriesSection({required this.book});

  @override
  State<_SeriesSection> createState() => _SeriesSectionState();
}

class _SeriesSectionState extends State<_SeriesSection> {
  SeriesInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = await bookRepository.getCachedSeries(widget.book.id);
    if (cached != null) {
      if (mounted) {
        setState(() {
          _info = cached;
          _loading = false;
        });
      }
      return;
    }

    final fetched = await HardcoverService().findSeriesForBook(
      widget.book.title,
      widget.book.author,
    );
    if (fetched != null) {
      await bookRepository.cacheSeries(widget.book.id, fetched);
    }
    if (mounted) {
      setState(() {
        _info = fetched;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (_loading || info == null || info.volumes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.series,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          info.seriesName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<BookEntry>>(
          stream: bookRepository.watchAll(),
          builder: (context, snapshot) {
            final localBooks = snapshot.data ?? [];
            final byTitle = {
              for (final b in localBooks) normalizeTitle(b.title): b,
            };

            return Column(
              children: info.volumes.map((volume) {
                // Check every known edition/translation of this volume - the
                // current book is flagged by Hardcover id (works regardless
                // of local title language); other volumes are matched by
                // whichever candidate title happens to match the shelf.
                var isCurrent = false;
                BookEntry? match;
                var displayCandidate = volume.primary;

                for (final candidate in volume.candidates) {
                  if (candidate.hardcoverBookId == info.currentVolumeId) {
                    isCurrent = true;
                    match = widget.book;
                    displayCandidate = candidate;
                    break;
                  }
                }
                if (!isCurrent) {
                  for (final candidate in volume.candidates) {
                    final found = byTitle[normalizeTitle(candidate.title)];
                    if (found != null) {
                      match = found;
                      displayCandidate = candidate;
                      break;
                    }
                  }
                }

                return _SeriesVolumeTile(
                  volume: volume,
                  displayTitle: displayCandidate.title,
                  searchTitle: volume.primary.title,
                  matchedBook: match,
                  isCurrent: isCurrent,
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SeriesVolumeTile extends StatelessWidget {
  final SeriesVolume volume;
  final String displayTitle;
  final String searchTitle;
  final BookEntry? matchedBook;
  final bool isCurrent;

  const _SeriesVolumeTile({
    required this.volume,
    required this.displayTitle,
    required this.searchTitle,
    required this.matchedBook,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final position = volume.position;
    final positionLabel = volume.details ??
        (position == null
            ? null
            : (position == position.roundToDouble()
                ? position.toInt().toString()
                : position.toString()));

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        child: Text(positionLabel ?? '?', style: const TextStyle(fontSize: 12)),
      ),
      title: Text(
        displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isCurrent ? const TextStyle(fontWeight: FontWeight.bold) : null,
      ),
      trailing: matchedBook != null
          ? _statusPill(
              context,
              BookStatus.fromDb(matchedBook!.status).label(context),
              primary: true,
            )
          : _statusPill(context, l10n.seriesNotOwned, primary: false),
      onTap: isCurrent
          ? null
          : () {
              if (matchedBook != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(bookId: matchedBook!.id),
                  ),
                );
              } else {
                openSeriesVolumeInSearch(context, searchTitle);
              }
            },
    );
  }

  Widget _statusPill(BuildContext context, String label, {required bool primary}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: primary ? scheme.primaryContainer : null,
        border: primary ? null : Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: primary ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}