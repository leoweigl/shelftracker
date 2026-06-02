class Book {
  final String title;
  final String author;
  final int? publicationYear;
  final String? coverUrl;
  final double? userRating;
  final List<String> categories;

  Book({
    required this.title,
    required this.author,
    this.publicationYear,
    this.coverUrl,
    this.userRating,
    this.categories = const [],
  });

  factory Book.fromOpenLibrary(Map<String, dynamic> json) {
    final coverId = json['cover_i'];
    final coverUrl = coverId != null
        ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
        : null;

    final authors = json['author_name'] as List?;
    final firstAuthor = (authors != null && authors.isNotEmpty)
        ? authors.first.toString()
        : 'Unbekannt';

    final rawSubjects = json['subject'] as List?;
    final categories = <String>{};
    if (rawSubjects != null) {
      for (final s in rawSubjects.take(5)) {
        final trimmed = s.toString().trim();
        if (trimmed.isNotEmpty) categories.add(trimmed);
      }
    }

    return Book(
      title: json['title']?.toString() ?? 'Ohne Titel',
      author: firstAuthor,
      publicationYear: json['first_publish_year'] as int?,
      coverUrl: coverUrl,
      categories: categories.toList(),
    );
  }

  factory Book.fromGoogleBooks(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    String? coverUrl;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    if (imageLinks != null) {
      final thumbnail = (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'])
          ?.toString();
      if (thumbnail != null) {
        coverUrl = thumbnail.replaceFirst('http://', 'https://');
      }
    }

    final authors = volumeInfo['authors'] as List?;
    final firstAuthor = (authors != null && authors.isNotEmpty)
        ? authors.first.toString()
        : 'Unbekannt';

    int? year;
    final publishedDate = volumeInfo['publishedDate']?.toString();
    if (publishedDate != null && publishedDate.length >= 4) {
      year = int.tryParse(publishedDate.substring(0, 4));
    }

    final rawCategories = volumeInfo['categories'] as List?;
    final categories = <String>{};
    if (rawCategories != null) {
      for (final raw in rawCategories) {
        for (final part in raw.toString().split('/')) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) categories.add(trimmed);
        }
      }
    }

    return Book(
      title: volumeInfo['title']?.toString() ?? 'Ohne Titel',
      author: firstAuthor,
      publicationYear: year,
      coverUrl: coverUrl,
      categories: categories.toList(),
    );
  }

}