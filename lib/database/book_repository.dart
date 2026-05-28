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

    return _db
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
}
