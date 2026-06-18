enum BookSort {
  title,
  author,
  rating,
  keep,
  addedAt,
}

extension BookSortLabel on BookSort {
  String get label {
    switch (this) {
      case BookSort.title:
        return 'Title';
      case BookSort.author:
        return 'Author';
      case BookSort.rating:
        return 'Rating';
      case BookSort.keep:
        return 'Keep / Sell';
      case BookSort.addedAt:
        return 'Added';
    }
  }
}