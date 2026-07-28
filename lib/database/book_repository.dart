import 'package:drift/drift.dart';
import 'package:shelftracker/models/wishlist_add_result.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import 'app_database.dart';
import '../models/book_sort.dart';

class ReadingLogItem {
  final ReadingLogEntry entry;
  final double? userRating;
  final bool isFavorite;
  final bool inShelf;

  ReadingLogItem({
    required this.entry,
    required this.userRating,
    required this.isFavorite,
    required this.inShelf,
  });
}

class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  Stream<List<BookEntry>> watchAll({
    BookSort sort = BookSort.title,
    bool ascending = true,
    BookStatus? status,
  }) {
    final query = _db.select(_db.books)
      ..where((b) {
        final notDeleted = b.isDeleted.equals(false);
        if (status != null) {
          return notDeleted & b.status.equals(status.name);
        }
        return notDeleted;
      });

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

  Future<void> updateRating(int id, double? rating) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(userRating: Value(rating)),
    );
  }

  Future<void> setKeep(int id, bool keep) {
    return (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(keepBook: Value(keep)),
    );
  }

  Future<void> delete(int id) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      const BooksCompanion(isDeleted: Value(true)),
    );
  }

  Future<void> setStatus(int id, BookStatus status) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(status: Value(status.name)),
    );
  }

  Stream<List<BookEntry>> watchWishlist() {
    return (_db.select(_db.books)
          ..where(
            (b) =>
                b.isDeleted.equals(false) &
                (b.status.equals(BookStatus.wishlist.name) |
                    b.status.equals(BookStatus.preordered.name)),
          )
          ..orderBy([(b) => OrderingTerm.asc(b.title)]))
        .watch();
  }

  Future<WishlistAddResult> addToWishlist(Book book) async {
    final existing =
        await (_db.select(_db.books)..where(
              (b) =>
                  b.title.lower().equals((book.title ?? '').toLowerCase()) &
                  b.author.lower().equals((book.author ?? '').toLowerCase()),
            ))
            .getSingleOrNull();

    if (existing != null && !existing.isDeleted) {
      if (existing.status == BookStatus.owned.name) {
        return WishlistAddResult.alreadyOwned;
      }
      if (existing.status == BookStatus.preordered.name) {
        return WishlistAddResult.alreadyPreordered;
      }
      return WishlistAddResult.alreadyWishlisted;
    }

    if (existing != null && existing.isDeleted) {
      await (_db.update(
        _db.books,
      )..where((b) => b.id.equals(existing.id))).write(
        const BooksCompanion(
          isDeleted: Value(false),
          status: Value('wishlist'),
        ),
      );
      return WishlistAddResult.added;
    }

    await _db
        .into(_db.books)
        .insert(
          BooksCompanion(
            title: Value(book.title ?? ''),
            author: Value(book.author ?? ''),
            publicationYear: Value(book.publicationYear),
            coverUrl: Value(book.coverUrl),
            description: Value(book.description),
            status: Value(BookStatus.wishlist.name),
          ),
        );
    return WishlistAddResult.added;
  }

  Future<int> addToShelf(Book book) => getOrCreateBookId(book);

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

  Future<void> setFavorite(int id, bool value) async {
    await (_db.update(_db.books)..where((b) => b.id.equals(id))).write(
      BooksCompanion(isFavorite: Value(value)),
    );
  }

  Future<int> getOrCreateBookId(Book book) async {
    var existing =
        await (_db.select(_db.books)..where(
              (b) =>
                  b.title.lower().equals((book.title ?? '').toLowerCase()) &
                  b.author.lower().equals((book.author ?? '').toLowerCase()),
            ))
            .getSingleOrNull();

    if (existing != null) {
      final needsUpdate =
          existing.isDeleted ||
          existing.status == BookStatus.wishlist.name ||
          existing.status == BookStatus.preordered.name;
      if (needsUpdate) {
        await (_db.update(
          _db.books,
        )..where((b) => b.id.equals(existing.id))).write(
          BooksCompanion(
            isDeleted: const Value(false),
            status: Value(BookStatus.owned.name),
          ),
        );
      }
      return existing.id;
    }

    final bookId = await _db
        .into(_db.books)
        .insert(
          BooksCompanion(
            title: Value(book.title ?? ''),
            author: Value(book.author ?? ''),
            publicationYear: Value(book.publicationYear),
            coverUrl: Value(book.coverUrl),
            description: Value(book.description),
            userRating: Value(book.userRating),
            status: Value(BookStatus.owned.name),
          ),
        );
    for (final categoryName in book.categories) {
      final categoryId = await getOrCreateCategory(categoryName);
      await addCategoryToBook(bookId, categoryId);
    }

    return bookId;
  }

  Future<void> logBookAsReadFromEntry(
    BookEntry entry, {
    DateTime? readDate,
  }) async {
    await setStatus(entry.id, BookStatus.owned);
    await _db
        .into(_db.readingLog)
        .insert(
          ReadingLogCompanion(
            title: Value(entry.title),
            author: Value(entry.author),
            coverUrl: Value(entry.coverUrl),
            bookId: Value(entry.id),
            readDate: Value(readDate ?? DateTime.now()),
          ),
        );
  }

  Future<void> logBookAsRead(Book book, {DateTime? readDate}) async {
    final bookId = await getOrCreateBookId(book);

    await _db
        .into(_db.readingLog)
        .insert(
          ReadingLogCompanion(
            title: Value(book.title ?? ''),
            author: Value(book.author ?? ''),
            coverUrl: Value(book.coverUrl),
            bookId: Value(bookId),
            readDate: Value(readDate ?? DateTime.now()),
          ),
        );
  }

  Stream<List<ReadingLogItem>> watchReadingLog() {
    final query =
        _db.select(_db.readingLog).join([
          leftOuterJoin(
            _db.books,
            _db.books.id.equalsExp(_db.readingLog.bookId),
          ),
        ])..orderBy([
          OrderingTerm(
            expression: _db.readingLog.readDate,
            mode: OrderingMode.desc,
          ),
        ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final entry = row.readTable(_db.readingLog);
        final book = row.readTableOrNull(_db.books);
        return ReadingLogItem(
          entry: entry,
          userRating: book?.userRating,
          isFavorite: book?.isFavorite ?? false,
          inShelf: book != null && !book.isDeleted,
        );
      }).toList();
    });
  }

  Stream<ReadingLogEntry> watchReadingLogById(int id) {
    return (_db.select(
      _db.readingLog,
    )..where((e) => e.id.equals(id))).watchSingle();
  }

  Future<void> updateReadDate(int logId, DateTime newDate) async {
    await (_db.update(_db.readingLog)..where((e) => e.id.equals(logId))).write(
      ReadingLogCompanion(readDate: Value(newDate)),
    );
  }

  Future<void> deleteLogEntry(int id) async {
    await (_db.delete(_db.readingLog)..where((e) => e.id.equals(id))).go();
  }
}
