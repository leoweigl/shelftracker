class Book {
  final String title;
  final String author;
  final int? publicationYear;
  final String? coverUrl;
  final double? userRating;

  Book({
    required this.title,
    required this.author,
    this.publicationYear,
    this.coverUrl,
    this.userRating,
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

    return Book(
      title: json['title']?.toString() ?? 'Ohne Titel',
      author: firstAuthor,
      publicationYear: json['first_publish_year'] as int?,
      coverUrl: coverUrl,
    );
  }
}