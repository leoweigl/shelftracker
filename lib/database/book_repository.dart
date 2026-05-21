import 'package:drift/drift.dart';
import '../models/book.dart';
import 'app_database.dart';

class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  Stream<List<BookEntry>> watchAll() {
    return _db.select(_db.books).watch();
  }

  Stream<BookEntry> watchById(int id) {
    return (_db.select(_db.books)..where((b) => b.id.equals(id))).watchSingle();
  }
  
  Future<List<BookEntry>> getAll() {
    return _db.select(_db.books).get();
  }
  
  Future<int> insertFromBook(Book book) {
    return _db.into(_db.books).insert(
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