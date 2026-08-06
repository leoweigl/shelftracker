import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('BookEntry')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text()();
  IntColumn get publicationYear => integer().nullable()();
  TextColumn get coverUrl => text().nullable()();
  RealColumn get userRating => real().nullable()();
  BoolColumn get isFinished => boolean().withDefault(const Constant(false))();
  BoolColumn get keepBook => boolean().withDefault(const Constant(true))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('owned'))();
  TextColumn get description => text().nullable()();
}

@DataClassName('CategoryEntry')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('BookCategoryEntry')
class BookCategories extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {bookId, categoryId};
}

@DataClassName('ReadingLogEntry')
class ReadingLog extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();
  TextColumn get author => text()();
  TextColumn get coverUrl => text().nullable()();

  IntColumn get bookId =>
      integer().nullable().references(Books, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get readDate => dateTime()();
}

@DataClassName('SeriesCacheEntry')
class SeriesCache extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {bookId};
}

@DriftDatabase(tables: [Books, Categories, BookCategories, ReadingLog, SeriesCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(categories);
        await m.createTable(bookCategories);
      }
      if (from < 3) {
        await m.addColumn(books, books.isFavorite);
      }
      if (from < 4) {
        await m.createTable(readingLog);
      }
      if (from < 5) {
        await m.addColumn(books, books.isDeleted);
      }
      if (from < 6) {
        await m.addColumn(books, books.status);
      }
      if (from < 7) {
        await m.addColumn(books, books.description);
      }
      if (from < 8) {
        await m.createTable(seriesCache);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'shelftracker_db');
  }
}