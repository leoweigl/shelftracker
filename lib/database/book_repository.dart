import 'package:drift/drift.dart';
import '../models/book.dart';
import 'app_database.dart';
import '../models/book_sort.dart';

class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  Stream<List<BookEntry>> watchAll({
    BookSort sort = BookSort.title,
    bool ascending = true,
  }) {
    final query = _db.select(_db.books);

    switch (sort) {
      case BookSort.title:
        query.orderBy([
          (b) => OrderingTerm(
            expression: b.title,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;

      case BookSort.author:
        query.orderBy([
          (b) => OrderingTerm(
            expression: b.author,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;

      case BookSort.rating:
        query.orderBy([
          (b) => OrderingTerm(
            expression: b.userRating,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
            nulls: NullsOrder.last,
          ),
          (b) => OrderingTerm.asc(b.title),
        ]);
        break;

      case BookSort.keep:
        query.orderBy([
          (b) => OrderingTerm(
            expression: b.keepBook,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
          (b) => OrderingTerm.asc(b.title),
        ]);
        break;

      case BookSort.addedAt:
        query.orderBy([
          (b) => OrderingTerm(
            expression: b.addedAt,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;
    }

    return query.watch();
  }

  Stream<BookEntry> watchById(int id) {
    return (_db.select(_db.books)..where((b) => b.id.equals(id))).watchSingle();
  }

  Future<List<BookEntry>> getAll() {
    return _db.select(_db.books).get();
  }

  Future<int?> insertFromBook(Book book) async {
    final existing =
        await (_db.select(_db.books)..where(
              (b) => b.title.equals(book.title) & b.author.equals(book.author),
            ))
            .get();

    if (existing.isNotEmpty) {
      return null;
    }

    final bookId = await _db
        .into(_db.books)
        .insert(
          BooksCompanion(
            title: Value(book.title),
            author: Value(book.author),
            publicationYear: Value(book.publicationYear),
            coverUrl: Value(book.coverUrl),
            userRating: Value(book.userRating),
          ),
        );

    for (final categoryName in book.categories) {
      final categoryId = await getOrCreateCategory(categoryName);
      await addCategoryToBook(bookId, categoryId);
    }
    return bookId;
  }

  Future<void> updateRating(int id, double? rating) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(userRating: Value(rating)),
    );
  }

  Future<void> setFinished(int id, bool isFinished) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(isFinished: Value(isFinished)),
    );
  }

  Future<void> setKeep(int id, bool keep) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(keepBook: Value(keep)),
    );
  }

  Future<int> delete(int id) {
    return (_db.delete(_db.books)..where((b) => b.id.equals(id))).go();
  }

  Future<int> getOrCreateCategory(String name) async {
    final trimmed = name.trim();

    final existing =
        await (_db.select(_db.categories)
              ..where((c) => c.name.lower().equals(trimmed.toLowerCase())))
            .getSingleOrNull();

    if (existing != null) return existing.id;

    return _db
        .into(_db.categories)
        .insert(CategoriesCompanion(name: Value(trimmed)));
  }

  Stream<List<CategoryEntry>> watchCategories() {
    return (_db.select(
      _db.categories,
    )..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  Future<void> addCategoryToBook(int bookId, int categoryId) async {
    await _db
        .into(_db.bookCategories)
        .insert(
          BookCategoriesCompanion(
            bookId: Value(bookId),
            categoryId: Value(categoryId),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> removeCategoryFromBook(int bookId, int categoryId) async {
    await (_db.delete(_db.bookCategories)..where(
          (bc) => bc.bookId.equals(bookId) & bc.categoryId.equals(categoryId),
        ))
        .go();
  }

  Stream<List<CategoryEntry>> watchCategoriesForBook(int bookId) {
    final query = _db.select(_db.categories).join([
      innerJoin(
        _db.bookCategories,
        _db.bookCategories.categoryId.equalsExp(_db.categories.id),
      ),
    ])..where(_db.bookCategories.bookId.equals(bookId));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(_db.categories)).toList(),
    );
  }

  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}
