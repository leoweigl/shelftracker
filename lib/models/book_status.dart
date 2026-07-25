import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';

enum BookStatus {
  wishlist,
  preordered,
  owned;

  static BookStatus fromDb(String value) =>
      BookStatus.values.firstWhere((s) => s.name == value, orElse: () => BookStatus.owned);

  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (this) {
      BookStatus.wishlist => l10n.statusWishlisted,
      BookStatus.preordered => l10n.statusPreordered,
      BookStatus.owned => l10n.statusOnShelf,
    };
  }
}
