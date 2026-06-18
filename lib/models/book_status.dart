enum BookStatus {
  wishlist,
  preordered,
  owned;

  static BookStatus fromDb(String value) =>
      BookStatus.values.firstWhere((s) => s.name == value, orElse: () => BookStatus.owned);

  String get label => switch (this) {
    BookStatus.wishlist => 'Wishlisted',
    BookStatus.preordered => 'Pre-ordered',
    BookStatus.owned => 'On shelf',
  };
}
