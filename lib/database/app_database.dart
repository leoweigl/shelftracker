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
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
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

@DriftDatabase(tables: [Books, Categories, BookCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'shelftracker_db');
  }
}