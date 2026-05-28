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
        return 'Titel';
      case BookSort.author:
        return 'Autor';
      case BookSort.rating:
        return 'Bewertung';
      case BookSort.keep:
        return 'Behalten / Verkaufen';
      case BookSort.addedAt:
        return 'Hinzugefügt';
    }
  }
}