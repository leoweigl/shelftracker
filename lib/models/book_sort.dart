import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

enum BookSort {
  title,
  author,
  rating,
  keep,
  addedAt,
}

extension BookSortLabel on BookSort {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case BookSort.title:
        return l10n.title;
      case BookSort.author:
        return l10n.author;
      case BookSort.rating:
        return l10n.rating;
      case BookSort.keep:
        return l10n.keepSell;
      case BookSort.addedAt:
        return l10n.added;
    }
  }
}