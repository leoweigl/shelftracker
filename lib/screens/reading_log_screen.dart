import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shelftracker/screens/log_detail_screen.dart';
import '../main.dart';
import '../database/book_repository.dart';
import '../l10n/app_localizations.dart';

class ReadingLogScreen extends StatefulWidget {
  const ReadingLogScreen({super.key});

  @override
  State<ReadingLogScreen> createState() => _ReadingLogScreenState();
}

class _ReadingLogScreenState extends State<ReadingLogScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  late Stream<List<ReadingLogItem>> _logStream;

  @override
  void initState() {
    super.initState();
    _logStream = bookRepository.watchReadingLog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      helpText: AppLocalizations.of(context)!.changeReadDate,
    );
    if (picked == null) return;
    await bookRepository.updateReadDate(logId, picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readingLog),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? l10n.closeSearch : l10n.search,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchTitleOrAuthor,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),
            ),
          Expanded(
            child: StreamBuilder<List<ReadingLogItem>>(
              stream: _logStream,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];

                final filteredItems = _searchQuery.isEmpty
                    ? items
                    : items
                          .where(
                            (i) =>
                                i.entry.title.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                i.entry.author.toLowerCase().contains(
                                  _searchQuery,
                                ),
                          )
                          .toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? l10n.noLogsYet
                          : l10n.noEntriesMatch,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final entry = item.entry;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 1,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.menu_book_rounded),
                              )
                            : const Icon(Icons.menu_book_rounded),
                        title: Text(
                          entry.title.isEmpty ? l10n.noTitle : entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.author.isEmpty
                                        ? l10n.unknown
                                        : entry.author,
                                  ),
                                ),
                                if (item.isFavorite) _favoritePill(context),
                              ],
                            ),
                            if (!item.inShelf) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _notOwnedPill(context),
                              ),
                            ],
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () => _editReadDate(
                                context,
                                entry.id,
                                entry.readDate,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.event, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${l10n.readOn} '
                                    '${DateFormat(l10n.dateFormat).format(entry.readDate)}',
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
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
            AppLocalizations.of(context)!.favorite,
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
        AppLocalizations.of(context)!.notInShelf,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
