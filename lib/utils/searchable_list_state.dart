import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../l10n/app_localizations.dart';

mixin SearchableListState<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isSearching = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        searchQuery = '';
      }
    });
  }

  void updateSearchQuery(String value) {
    setState(() => searchQuery = value.trim().toLowerCase());
  }

  IconButton buildSearchAction(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: Icon(isSearching ? Icons.close : Icons.search),
      tooltip: isSearching ? l10n.closeSearch : l10n.search,
      onPressed: toggleSearch,
    );
  }

  Widget buildSearchField(BuildContext context) {
    if (!isSearching) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.searchTitleOrAuthor,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
        onChanged: updateSearchQuery,
      ),
    );
  }

  List<BookEntry> filterBySearch(List<BookEntry> books) {
    if (searchQuery.isEmpty) return books;
    return books
        .where((b) =>
            b.title.toLowerCase().contains(searchQuery) ||
            b.author.toLowerCase().contains(searchQuery))
        .toList();
  }
}
